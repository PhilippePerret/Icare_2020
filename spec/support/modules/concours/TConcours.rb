# encoding: UTF-8
# frozen_string_literal: true
require './_lib/_pages_/concours/xrequired/constants'

class TConcours
class << self

  def reset
    # Vide les tables
    db_exec("TRUNCATE TABLE #{DBTBL_CONCOURS}")
    db_exec("TRUNCATE TABLE #{DBTBL_CONCURRENTS}")
    db_exec("TRUNCATE TABLE #{DBTBL_CONCURS_PER_CONCOURS}")
    # Vide les classes
    TConcurrent.reset
    # Détruit les dossiers des fichiers
    FileUtils.rm_rf(CONCOURS_DATA_FOLDER)
    `mkdir -p #{CONCOURS_DATA_FOLDER}`
  end #/ reset

  def current
    @current ||= new(ANNEE_CONCOURS_COURANTE)
  end #/ current

  def jury
    @jury ||= begin
      require './_lib/data/secret/concours'
      CONCOURS_DATA[:evaluators]
    end
  end #/ jury

  # Peuple les tables concours avec des données aléatoires
  #
  # - Chaque concurrent a participé à chaque concours
  # - Tous les concurrents ont produit un fichier
  #
  def peuple
    require './spec/support/data/concours_data'
    path_pdf_file = File.expand_path(File.join('.','spec','support','asset','documents','autre_doc.pdf'))
    # D'abord on crée les concours
    ANNEES_CONCOURS_TESTS.uniq.each do |annee, dannee|
      theme = random_theme
      # phase = annee < (Time.now.month < 3 ? Time.now.year : Time.now.year + 1) ? 9 : 1
      phase = annee < ANNEE_CONCOURS_COURANTE ? 9 : 1
      db_compose_insert(DBTBL_CONCOURS, {annee:annee, phase:phase, theme:theme, theme_d:"L'explication du thème “#{theme}”", prix1: "1000€", prix2:"800€", prix3:"200€"})
    end
    # On crée les concurrents
    DATA_CONCURRENTS.each do |dc|
      # puts "dc: #{dc.inspect}"
      data_participations = dc.delete(:data_participations)
      db_compose_insert(DBTBL_CONCURRENTS, dc)
      data_participations.each do |dp|
        # Créer l'enregistrement pour la participation au concours
        db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, dp)
        if dp[:specs][0] == "1"
          # Créer le dossier du concurrent avec son fichier pour
          # cette participation
          filename = "#{dp[:concurrent_id]}-#{dp[:annee]}.pdf"
          filepath = File.join(CONCOURS_DATA_FOLDER,dp[:concurrent_id],filename)
          `mkdir -p "#{File.dirname(filepath)}"`
          FileUtils.cp(path_pdf_file, filepath)
        end
      end
    end
  end #/ peuple

  # Pour changer la phase courante du concours
  def set_phase(phase, annee = nil)
    db_exec(REQUEST_CHANGE_STEP, [phase, annee || ANNEE_CONCOURS_COURANTE])

    # Pour la phase 0, il faut également s'assurer qu'il n'y a aucun document
    # pour cette année là dans les synopsis.
    # Il faut aussi supprimer toutes les inscriptions (pas les concurrents) pour
    # cette année-là.
    if phase == 0
      Dir["#{CONCOURS_DATA_FOLDER}/**/*-#{ANNEE_CONCOURS_COURANTE}.*"].each do |f|
        # puts "DELETE #{f}"
        File.delete(f)
      end
      request = "DELETE FROM concurrents_per_concours WHERE annee = ?"
      db_exec(request, [ANNEE_CONCOURS_COURANTE])
    end
  end #/ set_phase


end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :annee
def initialize(annee)
  @annee = annee
end #/ initialize

def reset
  @data   = nil
  @theme  = nil
  @phase  = nil
end #/ reset

def theme;    @theme ||= data[:theme]   end
def phase;    @phase ||= data[:phase]   end

def data
  @data ||= db_exec(REQUEST_DATA_CONCOURS,annee).first || {}
end #/ data

def set_phase(value)
  self.class.set_phase(value, annee)
end #/ set_phase
# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------

REQUEST_DATA_CONCOURS = "SELECT * FROM concours WHERE annee = ?"

REQUEST_CHANGE_STEP = "UPDATE concours SET phase = ? WHERE annee = ?"


end #/TConcours
