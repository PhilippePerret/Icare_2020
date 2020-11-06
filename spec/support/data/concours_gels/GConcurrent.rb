# encoding: UTF-8
# frozen_string_literal: true
# ---------------------------------------------------------------------
#
#   CLASSE GConcurrent
#   --------------------
#   Gestion des gels pour les concurrents
#
# ---------------------------------------------------------------------
class GConcurrent
class << self
  attr_reader :nombre_courants, :nombre_cur_file_conforme, :nombre_selecteds, :nombre_primeds, :nombre_avec_fiche_lecture, :nombre_avec_informations

  def reset_all
    @nombre_courants = 0
    @nombre_cur_file_conforme = 0
    @nombre_selecteds = 0
    @nombre_primeds = 0
    @nombre_avec_fiche_lecture = 0
    @nombre_avec_informations = 0
  end #/ reset_all

  def incremente_nombre_courants
    @nombre_courants += 1
  end #/ incremente_nombre_courants
  def incremente_fichiers_cur_conformes
    @nombre_cur_file_conforme += 1
  end #/ incremente_fichiers_cur_conformes
  def incremente_selecteds
    @nombre_selecteds += 1
  end #/ incremente_selecteds
  def incremente_primeds
    @nombre_primeds += 1
  end #/ incremente_primeds

  def incremente_avec_fiche_lecture
    @nombre_avec_fiche_lecture += 1
  end #/ incremente_avec_fiche_lecture

  def incremente_avec_informations
    @nombre_avec_informations += 1
  end #/ incremente_avec_informations

  def data_folder
    @data_folder ||= File.expand_path(File.join('_lib','data','concours'))
  end #/ data_folder
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :id, :patronyme, :sexe, :options, :created_ds, :participations
def initialize(data_ini)
  @data_ini = data_ini
  @data_ini.each{|k,v|instance_variable_set("@#{k}", v)}
end #/ initialize
alias :pseudo :patronyme
# = main =
# Méthode principale de fabrication du concurrent
def build
  make_folder
  traite_participations
  save_data_in_db
end #/ build
# ---------------------------------------------------------------------
#   MÉTHODES DE BASE DE DONNÉES
# ---------------------------------------------------------------------
def save_data_in_db
  db_compose_insert(DBTBL_CONCURRENTS, db_data)
end #/ save_data_in_db
# ---------------------------------------------------------------------
#   MÉTHODES DE FABRICATION
# ---------------------------------------------------------------------
def make_folder
  `mkdir -p "#{folder}"`
end
def traite_participations
  participations.each do |annee, data_participation|
    traite_participation(data_participation.merge(annee: annee))
  end
end #/ traite_participations
def traite_participation(pdata)
  Participation.new(self, pdata).build
end #/ traite_participation
# ---------------------------------------------------------------------
#   MÉTHODES DE COMPOSITION DES DONNÉES
# ---------------------------------------------------------------------
def db_data
  @db_data ||= {
    concurrent_id: id,
    patronyme: patronyme,
    session_id: "238YFU889",
    mail: mail,
    sexe: sexe,
    options: calcule_options,
    created_at: created_at
  }
end #/ db_data
def mail
  @mail ||= "#{pseudo.downcase.gsub(/[ \-]/,'.')}@gmail.com"
end #/ mail
def calcule_options
  @options ||= {}
  os = Array.new(8,"0")
  os[0] = "1" unless options[:informations] === false
  GConcurrent.incremente_avec_informations if os[0] == "1"
  os[1] = "1" unless options[:fiche_lecture] === false
  GConcurrent.incremente_avec_fiche_lecture if os[1] == "1"
  os[2] = "1" if not(options[:icarien].is_a?(Integer)) # ID icarien
  os.join('')
end #/ calcule_options
def concurrent_id
  @concurrent_id ||= created_ds.gsub(/[\/\:]/,'')
end #/ concurrent_id
alias :id :concurrent_id
def created_at
  @created_at ||= DateString.new(created_ds).to_time.to_i.to_s
end #/ created_at
# ---------------------------------------------------------------------
#   DONNÉES
# ---------------------------------------------------------------------
def folder
  @folder ||= File.join(self.class.data_folder, concurrent_id)
end
# ---------------------------------------------------------------------
#
#   Classe GConcurrent::Participation
#   -----------------------------------
#   Gestion de la participation à un concours
#
# ---------------------------------------------------------------------
class Participation
  attr_reader :concurrent, :data_ini
  attr_reader :annee, :fichier, :titre, :notes
  attr_reader :preselected, :prix, :pre_note, :fin_note
  attr_accessor :specs # composé ici
  def initialize(concurrent, data_ini)
    @concurrent = concurrent
    @data_ini   = data_ini
    @data_ini.each{|k,v|instance_variable_set("@#{k}", v)}
    @is_current = @annee == :current
    @annee = ANNEE_CONCOURS_COURANTE if @annee == :current
    @preselected = true if @prix.to_i > 0

    if PHASE_GEL > 0
      @fichier = {} if @fichier.nil?
      @fichier.merge!(name: "peuimporte.pdf") unless @fichier.key?(:name)
      @fichier.merge!(conforme: true) unless @fichier.key?(:conforme)
    end

    if current?
      GConcurrent.incremente_nombre_courants
    end

  end #/ initialize

  def current?
    @is_current === true
  end #/ current?

  # = main =
  # Méthode principale qui construit la participation courante pour
  # le concurrent
  def build
    compose_specs
    make_folder_evaluations if not(current? && PHASE_GEL == 0)
    make_evaluations_and_calc_notes if PHASE_GEL > 1
    save_data_in_db
  end #/ build
  # ---------------------------------------------------------------------
  #   MÉTHODES DE BASE DE DONNÉES
  # ---------------------------------------------------------------------
  def save_data_in_db
    db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, db_data)
  end #/ save_data_in_db
  # ---------------------------------------------------------------------
  #   MÉTHODES DE FABRICATION
  # ---------------------------------------------------------------------
  # DO    Produit le fichier de candidature pour le concurrent
  def make_fichier_candidature
    # puts "Fabrication de : #{fichier_candidature_path}"
    FileUtils.copy(TEMPLATE_FICHIER_CANDIDATURE, fichier_candidature_path)
  end #/ make_fichier_candidature
  def make_folder_evaluations
    FileUtils.mkdir_p(folder_evaluations_path)
    # `mkdir -p "#{folder_evaluations_path}"`
  end #/ make_folder_evaluations
  # ---------------------------------------------------------------------
  #   MÉTHODES DE FABRICATION DE DONNÉES
  # ---------------------------------------------------------------------
  def db_data
    @db_data ||= begin
      {
        annee: annee,
        concurrent_id: concurrent.id,
        specs: specs,
        titre: titre,
        auteurs: data_ini[:auteurs],
        keywords: data_ini[:keywords],
        prix: prix,
        pre_note: pre_note,
        fin_note: fin_note,
        created_at: created_at,
        updated_at: created_at
      }
    end
  end #/ db_data
  def compose_specs
    sp = Array.new(8,"0")
    # Envoi fichier
    if PHASE_GEL > 0
      # puts "fichier: #{fichier.inspect}"
      unless fichier[:name].nil?
        sp[0] = "1"
        make_fichier_candidature
      end
      # Conformité
      sp[1] = case fichier[:conforme]
              when NilClass then "0"
              when true     then "1"
              when false    then "2"
              end
      GConcurrent.incremente_fichiers_cur_conformes if current? && sp[1] == "1"
      if PHASE_GEL >= 2
        # Présélection
        sp[2] = "1" if preselected === true
        GConcurrent.incremente_selecteds if current? && sp[2] == "1"
        if PHASE_GEL >= 3
          # Lauréat
          sp[3] = prix unless prix.nil?
          GConcurrent.incremente_primeds if current? && sp[3].to_i > 0
        end
      end
    end
    self.specs = sp.join("")
  end #/ compose_specs
  def created_at
    @created_at ||= (Time.new(annee,3,1).to_i - rand(200.days)).to_s
  end

  # Pour le calcul de la note finale du concurrent (champ pre_note pour la
  # note de présélection et fin_note pour la note finale si présélectionné)
  # Note : pour le moment, dans les notes, pour les lauréats, on prend pour la
  # note finale la même que la note de présélection
  def make_evaluations_and_calc_notes
    return if not(current?) || notes.nil?
    note = 0
    notes.each_with_index do |n, idx|
      note += n.to_i
      filename = "evaluation-pres-#{idx + 1}.json"
      dst = File.join(folder_evaluations_path, filename)
      src = File.join(__dir__,'modeles','evaluations',"note#{n}.json")
      FileUtils.copy(src,dst)
    end
    note = (note.to_f / notes.count).to_i
    @pre_note = note
    @fin_note = note if primed?
  end #/ make_evaluations_and_calc_notes
  # ---------------------------------------------------------------------
  #   DONNÉES
  # ---------------------------------------------------------------------
  def fichier_candidature_path
    @fichier_candidature_path ||= File.join(concurrent.folder, filename)
  end
  def filename
    @filename ||= "#{concurrent.id}-#{annee}#{File.extname(fichier[:name])}"
  end
  def folder_evaluations_path
    @folder_evaluations_path ||= File.join(concurrent.folder,"#{concurrent.id}-#{annee}")
  end
  def primed?
    (@is_primed ||= begin
      prix.to_i > 0 ? :true : :false
    end) == :true
  end #/ primed?
end #/GConcurrent::Participation

end #/GConcurrent
