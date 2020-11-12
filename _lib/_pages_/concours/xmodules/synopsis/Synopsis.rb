# encoding: UTF-8
# frozen_string_literal: true
=begin
  La classe Synopsis pour la gestion d'un synopsis
  Un synopsis est désigné par un :concurrent_id (identifiant du concurrent)
  et une année (année du concours).
  Noter que l'instance existe même lorsque le fichier de candidature n'a
  pas été envoyé. Mais dans ce cas, l'évaluation n'est pas encore possible.
=end
require_relative './constants'
require_relative './FicheLecture'
require_relative './Evaluation'

class Synopsis
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

def get(syno_id)
  @table ||= {}
  @table[syno_id] ||= begin
    args = syno_id.split('-')
    args << db_exec(REQUEST_SYNOPSIS, args).first
    Synopsis.new(*args)
  end
end #/ get

  # Retourne la liste de tous les synopsis courants (sous forme d'instances
  # synopsis). Note : il y en a une par concurrent de la session courante,
  # même s'il n'a pas encore envoyé son fichier de candidature
  # Processus :
  #   On relève dans la base les concurrents de l'année courante
  #
  def all_courant
    @all_courant ||= begin
      db_exec(REQUEST_ALL_CONCURRENTS, [ANNEE_CONCOURS_COURANTE]).collect do |dc|
        dc.merge!(evaluator_id: Concours.evaluator.id)
        log("dc : #{dc.inspect}")
        Synopsis.new(dc[:concurrent_id], ANNEE_CONCOURS_COURANTE, dc)
      end
    end
  end #/ all_courant

  # IN    La clé de classement ('note' ou 'progress')
  #       Le sens de classement ('desc' ou 'asc')
  #       +options+ Table d'options
  #         :preselecteds   Si true, seulement les présélectionnés
  #         :avec_fichier   Si true, seulement les synopsis avec fichier conforme
  # OUT   La liste des instances {Synopsis}
  # Note  Les synopsis sans fichiers sont toujours mis à la fin
  def sorted_by(key = 'note', sens = 'desc', options = nil)
    options ||= {}
    # 1) On ne prend que les synopsis avec fichier
    avec_fichiers = []
    sans_fichiers = []
    all_courant.each do |syno|
      if syno.fichier?
        if options[:preselecteds]
          avec_fichiers << syno if syno.preselected?
        elsif options[:avec_fichier_conforme]
          avec_fichiers << syno if syno.cfile.conforme?
        else
          avec_fichiers << syno
        end
      else
        sans_fichiers << syno
      end
    end
    # 2) On peut classer les synopsis avec fichier
    if key == 'note'
      # avec_fichiers = avec_fichiers.sort_by{ |syno| syno.fiche_lecture.total.note }.reverse
      avec_fichiers = avec_fichiers.sort_by{ |syno| syno.note.to_f }
      avec_fichiers.each_with_index { |syno, idx| syno.position = idx + 1 unless syno.fiche_lecture.total(options).undefined? }
    else # ket = :progress
      avec_fichiers.sort_by! { |syno| syno.evaluation_for(html.evaluator.id).nombre_reponses||0 }
    end
    avec_fichiers = avec_fichiers.reverse if sens == 'desc'
    if options[:avec_fichier] || options[:avec_fichier_conforme]
      avec_fichiers
    elsif options[:avec_fichier] === false || options[:sans_fichier]
      sans_fichiers
    else
      avec_fichiers + sans_fichiers
    end
  end #/ sorted_by
end # /<< self





# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent_id, :annee, :data, :id
# Les données de score pour un évaluator donné
# Note : pour le moment, l'évaluateur se donne dans :out
attr_reader :data_score
# L'évaluator courant
attr_accessor :evaluator_id
# Position de classement par rapport à la note
attr_accessor :position

# Instanciation
def initialize concurrent_id, annee, dat = nil
  @concurrent_id = concurrent_id
  @annee = annee
  @id = "#{concurrent_id}-#{annee}"
  @data = dat || get_data
  @evaluator_id = @data[:evaluator_id]
end #/ initialize

# Évaluation en temps courant, en fonction du visiteur (admin, evaluator ou
# concurrent) et la phase du concours. Sachant que :
#   PHASE 0
#     - Personne ne peut rien voir.
#   PHASE 1
#     - L'administrateur peut voir sa note, la note générale et la note de
#       chaque membre du jury (peut-être en rangée)
#     - un évaluateur du jury 1 peut voir sa fiche (et la modifier)
#     - un évaluateur du jury 2 ne peut rien voir
#     - un concurrent ne peut rien voir
#   PHASE 2 (présélection)
#     - Un administrateur peut voir sa note et la note générale
#     - Un concurrent ne peut rien voir
#     - Un évaluateur du jury 1 peut voir sa fiche (et la modifier)
#     - Un évaluateur du jury 2 ne peut rien voir
#   PHASE 3 (synopsis présélectionnés)
#     - Un administrateur peut tout voir, dans le détail
#     - Un évaluateur de jury 1 peut voir sa note et la note générale
#     - Un évaluateur de jury 2 peut voir sa note (et la modifier)
#     - Un concurrent peut voir sa note de présélections
#   PHASE 5 (palmarès établi)
#     - Un administrateur peut tout voir, dans le détail
#     - Un évaluateur de jury 1 peut voir sa note et la note générale
#     - Un évaluateur de jury 2 peut voir sa note et la note générale
#       (il ne peut plus modifier sa note)
#     - Un concurrent peut voir sa note et son prix (if any)
#   Idem pour les phases suivantes
# def evaluate
#
# end #/ evaluate

def evaluation_for(jure_id)
  @evaluations ||= {}
  @evaluations[jure_id] ||= begin
    Evaluation.new(checklist_for(jure_id))
  end
end

def evaluation_for_all
  @evaluate_all ||= begin
    Evaluation.new(checklist_paths)
  end
end #/ evaluate_all

# OUT   Le path du fichier d'évaluation en fonction de la phase +phase+
#       du concours et l'évaluateur d'identifiant +ev_id+ (ou l'évaluateur
#       courant)
def checklist_for(jure_id = nil, phase = nil)
  checklist_paths(phase, jure_id ||= @evaluator_id)
end

# OUT   {Array} Liste des fichiers d'évaluation (en fonction de la phase
#       courante ou stipulée)
#
# IN    {Integer} Phase du concours pour laquelle il faut voir la liste. Si
#       la phase est inférieure à 5, ce sont les fiches d'évaluation des
#       présélections, sinon, ce sont les fiches d'évaluation du palmarès (ça
#       ne change que pour les sélectionnés)
def checklist_paths(phase = nil, evaluator_id = nil)
  phase ||= Concours.current.phase
  key_phase = phase >= 3 && preselected? ? 'prix' : 'pres'
  ary = Dir["#{folder}/evaluation-#{key_phase}-#{evaluator_id.nil? ? '*' : evaluator_id}.json"]
  if evaluator_id.nil?
    ary
  else
    ary.first
  end
end #/ all_checklist_paths

# OUT   True si le synopsis fait partie des présélectionnés
def preselected?
  concurrent.spec(2) == 1
end

def cfile
  @cfile ||= Concours::CFile.new(concurrent, annee, self)
end #/ cfile

def template_fiche_synopsis
  @template_fiche_synopsis ||= begin
    deserb('templates/fiche_synopsis_template', self)
  end
end #/ template_fiche_synopsis

def template_fiche_classement
  @template_fiche_classement ||= begin
    deserb('templates/fiche_classement', self)
  end
end #/ template_fiche_classement

def bind; binding() end

# OUT   Le synopsis sous forme de ficher, soit celle d'un évaluateur
#       en particulier (si +evaluator_id+ est défini) soit, la fiche
#       générale, toutes notes confondues
# IN    Optionnellement, ID de l'évaluateur ou table des options
#       Note : il peut être fourni à l'instanciation (cf. initialize)
def out(options = nil)
  options = {evaluator_id: options} if options.is_a?(Integer)
  options ||= options
  options.merge!(format: :fiche_synopsis) unless options.key?(:format)
  @evaluator_id ||= options[:evaluator_id]
  data_template = {
    id: concurrent.id,
    exergue: (concurrent.id == options[:current_cid] ? ' current' : ''),
    position: options[:position]
  }
  case options[:format]
  when :fiche_synopsis
    template_fiche_synopsis
  when :fiche_classement
    template_fiche_classement % data_template
  end
end #/ out

def css_classes
  @css ||= begin
    c = ["synopsis"]
    c << "ghost" if not(fichier?)
    c << "not-conforme" if cfile.conformity_defined? && not(cfile.conforme?)
    c.join(' ')
  end
end #/ css
# Pour sauver les données
def save(data)
  if data.key?(:keywords)
    data[:keywords] = data[:keywords].split(',').collect{|w|w.strip}.join(',')
  end
  if data.key?(:titre)
    raise("Il faut un titre !") if data[:titre].nil_if_empty.nil?
  end
  values  = data.values
  columns = data.keys.collect { |k| "#{k} = ?" }.join(", ")
  values << concurrent_id
  values << annee
  db_exec("UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET #{columns} WHERE concurrent_id = ? AND annee = ?", values)
  # Pour actualiser
  data.each {|k,v| instance_variable_set("@#{k}", v)}
end #/ save

# IN    {Float} Une valeur réelle, normalement flottante
# OUT   {String} Le nombre pour affichage. Principale, sans ".0" à la fin
#       s'il y en a un
def formate_note(v)
  if v.nil?
    '---'
  elsif v.to_i == v
    v.to_i
  else
    v
  end.to_s
end #/ formate_float


def titre;    @titre    ||= data[:titre]    end
def specs;    @specs    ||= data[:specs]    end
def auteurs;  @auteurs  ||= data[:auteurs]  end
def keywords; @keywords ||= data[:keywords] end
def pre_note; @pre_note ||= data[:pre_note] end
def fin_note; @fin_note ||= data[:fin_note] end

def real_auteurs
  auteurs || concurrent.patronyme
end #/ formated_auteurs

def concurrent
  @concurrent ||= Concurrent.get(concurrent_id)
end #/ concurrent

# Son instance de fiche de lecture
def fiche_lecture
  @fiche_lecture ||= FicheLecture.new(self)
end #/ fiche_lecture

# OUT   La note générale pour un évaluateur donné
#       (sinon, pour la note moyenne, cf. formated_pre_note ou
#        formated_fin_note)
def formated_note
  note || "---"
end

def formated_note_globale
  note_globale || "---"
end #/ formated_note_globale

def formated_auteurs
  @formated_auteurs ||= begin
    if auteurs.nil?
      concurrent.pseudo
    else
      auteurs
    end
  end
end #/ formated_auteurs


def formated_keywords
  @formated_keywords ||= (data[:keywords]||'').split(',').collect{|kw| "<span class=\"kword\">#{kw}</span>"}.join(' ')
end #/ keywords

def formated_pre_note
  if pre_note.nil?
    calcule_note_preselection
  end
  color = pre_note > 100 ? 'green' : 'red'
  Tag.span(text:"#{pre_note}/200", class:color)
end #/ formated_note

# Son instance de formulaire d'évaluation, pour un évaluateur donné
def evaluation_form(evaluateur)
  @evaluations ||= {}
  @evaluations[evaluateur.id] || begin
    @evaluations.merge!(evaluateur.id => EvaluationForm.new(self, evaluateur))
  end
  @evaluations[evaluateur.id]
end #/ evaluation

# ---------------------------------------------------------------------
#   Méthodes d'état
# ---------------------------------------------------------------------

# OUT   True si le fichier de candidature a été envoyé
def fichier?
  data[:with_fichier] == 1
end #/ fichier?

# ---------------------------------------------------------------------
#   Méthods de chemins
# ---------------------------------------------------------------------

# IN    ID de l'évaluateur (pour la session 2020, ça correspond à l'ID User)
# OUT   Chemin d'accès au fichier d'évaluation (score) pour l'évaluator evaluator_id
def score_path_for(evaluator_id, phase)
  key_phase = phase > 3 && preselected? ? 'prix' : 'pres'
  File.join(folder,"evaluation-#{key_phase}-#{evaluator_id}.json")
end #/ score_path
# Chemin d'accès au dossier du synopsis, où sont rangées tous les fichiers,
# et notamment les fichiers d'évaluation
def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER,concurrent_id,affixe).tap{|p|`mkdir -p "#{p}"`}
end #/ folder

# Chemin d'accès au fichier synopsis
# Puisque le path est trouvé de façon dynamique, on peut interroger path.nil?
# pour savoir si le fichier existe.
def path
  @path ||= begin
    Dir["#{CONCOURS_DATA_FOLDER}/#{concurrent_id}/#{affixe}.*"].first
  end
end #/ path

def affixe
  @affixe ||= "#{concurrent_id}-#{annee}"
end #/ affixe


private

  def get_data
    cpc_data = db_exec(REQUEST_SYNOPSIS, [concurrent_id, annee]).first
    @synopsis_exists = !cpc_data.nil?
    # puts "cpc_data = #{cpc_data.inspect}"
    cpc_data || {}
  end #/ get_data

# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------

# Pour récupérer les données d'un ~synopsis en particulier.
REQUEST_SYNOPSIS = <<-SQL
SELECT *
  FROM #{DBTBL_CONCURS_PER_CONCOURS}
  WHERE concurrent_id = ? AND annee = ?
SQL

# On prend tous les participants et ceux qui n'ont pas
# encore envoyé de synopsis, le synopsis est marqué "ghost"
REQUEST_ALL_CONCURRENTS = <<-SQL
SELECT
  cc.concurrent_id, cc.patronyme,
  cpc.*, (SUBSTRING(cpc.specs,1,1) = "1") AS with_fichier
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ? -- AND SUBSTRING(cpc.specs,1,1) = "1"
SQL


end #/Synopsis
