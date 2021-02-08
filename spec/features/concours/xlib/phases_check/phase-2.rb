# encoding: UTF-8
# frozen_string_literal: true
=begin
  Check du bon déroulé de la phase 2
  La méthode check_phase_2 s'assure que tout a bien été opéré après
  que l'administrateur a fait passer le concours en phase 2.
  C'est-à-dire :

=end

def check_phase_2
  # L'accueil du concours est conforme à ce qu'on attend
  goto("concours/accueil")
  screenshot("accueil-after-passage-phase-2")


  expect(page).to have_content(/Les [0-9]+ synopsis sont en cours de présélection\./),
    "On devrait voir le nombre de synopsis en présélection."

  expect(page).not_to have_css('a[href="concours/inscription"]', text:/(inscription|inscrivez\-vous)/i),
    "On ne devrait plus pouvoir s'inscrire au concours, pendant la sélection"

  # db_count(DBTBL_CONCURS_PER_CONCOURS, "annee = #{ANNEE_CONCOURS_COURANTE} AND SUBSTRING(specs,2,1) = 1")
  # On récupère toutes inscription pour ce concours-là
  candidatures = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ?", [ANNEE_CONCOURS_COURANTE])

  sans_dossier  = candidatures.select { |dc| dc[:specs][0]    == '0' }
  conformes     = candidatures.select { |dc| dc[:specs][0..1] == '11'}
  non_conformes = candidatures.select { |dc| dc[:specs][0..1] == '12'}

  if sans_dossier.empty?
    raise "Il faudrait au moins une candidature sans dossier, pour pouvoir bien checher."
  end
  if conformes.empty?
    raise "Il faudrait au moins une candidature avec dossier conforme, pour pouvoir bien checher."
  end
  if non_conformes.empty?
    raise "Il faudrait au moins une candidature avec dossier non conforme, pour pouvoir bien checher."
  end

  # Tous les concurrents ont reçu un mail annonçant la fin de l'échéance
  # avec le bon texte en fonction de :
  #   - l'envoi d'un dossier conforme
  #   - l'envoi d'un dossier non conforme (non corrigé)
  #   - le non envoi du dossier
  # TODO
  # Les membres du jury 1 ont reçu un mail informatif
  # TODO
  # Les membres du jury 2 ont reçu unm ail seulement informatif

end #/ check_phase_2
