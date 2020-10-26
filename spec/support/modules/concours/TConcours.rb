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
      # step = annee < (Time.now.month < 3 ? Time.now.year : Time.now.year + 1) ? 9 : 1
      step = annee < ANNEE_CONCOURS_COURANTE ? 9 : 1
      db_compose_insert(DBTBL_CONCOURS, {annee:annee, step:step, theme:theme, theme_d:"L'explication du thème “#{theme}”", prix1: "1000€", prix2:"800€", prix3:"200€"})
    end
    # On crée les concurrents
    DATA_CONCURRENTS.each do |dc|
      data_participations = dc.delete(:data_participations)
      db_compose_insert(DBTBL_CONCURRENTS, dc)
      data_participations.each do |dp|
        # Créer l'enregistrement pour la participation au concours
        db_compose_insert(DBTBL_CONCURS_PER_CONCOURS, dp)
        # Créer le dossier du concurrent avec son fichier pour
        # cette participation
        filename = "#{dp[:concurrent_id]}-#{dp[:annee]}.pdf"
        filepath = File.join(CONCOURS_DATA_FOLDER,dp[:concurrent_id],filename)
        `mkdir -p "#{File.dirname(filepath)}"`
        FileUtils.cp(path_pdf_file, filepath)
      end
    end
  end #/ peuple

end # /<< self
end #/TConcours
