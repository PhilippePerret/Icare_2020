# encoding: UTF-8
# frozen_string_literal: true
=begin
  Check du bon déroulé de la phase 2
  La méthode check_phase_2 s'assure que tout a bien été opéré après
  que l'administrateur a fait passer le concours en phase 2.
  C'est-à-dire :

=end

def check_phase_2

  start_time = Time.now.to_i - 4

  # On récupère toutes inscription pour ce concours-là
  candidatures = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ?", [ANNEE_CONCOURS_COURANTE])
  sans_dossiers = candidatures.select { |dc| dc[:specs][0]    == '0' }
  conformes     = candidatures.select { |dc| dc[:specs][0..1] == '11'}
  non_conformes = candidatures.select { |dc| dc[:specs][0..1] == '12'}
  
  # Check (mais normalement, la procédure ensure_phase_2 a dû régler ce
  # problème)
  if sans_dossiers.empty?
    raise "Il faudrait au moins une candidature sans dossier, pour pouvoir bien checher."
  end
  if conformes.empty?
    raise "Il faudrait au moins une candidature avec dossier conforme, pour pouvoir bien checher."
  end
  if non_conformes.empty?
    raise "Il faudrait au moins une candidature avec dossier non conforme, pour pouvoir bien checher."
  end

  # L'accueil du concours est conforme à ce qu'on attend
  goto("concours/accueil")
  screenshot("accueil-after-passage-phase-2")


  expect(page).to have_content("Les #{conformes.count} synopsis sont en cours de présélection."), "On devrait voir le nombre de synopsis en présélection."
  pitch("La page d'accueil du concours annonce bien le nombre de synopsis (#{conformes.count}) en cours de présélection")

  expect(page).not_to have_css('a[href="concours/inscription"]', text:/(inscription|inscrivez\-vous)/i), "On ne devrait plus pouvoir s'inscrire au concours, pendant la sélection"
  pitch("Le lien pour rejoindre le formulaire d'inscription a été supprimé.")

  # Tous les concurrents ont reçu un mail annonçant la fin de l'échéance
  # avec le bon texte en fonction de :
  #   - l'envoi d'un dossier conforme
  #   - l'envoi d'un dossier non conforme (non corrigé)
  #   - le non envoi du dossier
  conformes.each do |dc|
    conc = TConcurrent.get(dc[:concurrent_id])
    expect(conc).to have_mail({after:start_time, subject:'Fin de l’échéance des dépôts', message:'transmis un fichier de candidature conforme'})
  end
  pitch("Les #{conformes.count} concurrents avec dossier conforme ont bien reçu le mail")
  sans_dossiers.each do |dc|
    conc = TConcurrent.get(dc[:concurrent_id])
    expect(conc).to have_mail({after:start_time, subject:'Fin de l’échéance des dépôts', message:'pas transmis de fichier de candidature conforme'})
  end
  pitch("Les #{sans_dossiers.count} concurrents sans dossier ont reçu le bon mail")
  non_conformes.each do |dc|
    conc = TConcurrent.get(dc[:concurrent_id])
    expect(conc).to have_mail({after:start_time, subject:'Fin de l’échéance des dépôts', message:'pas transmis de fichier de candidature conforme'})
  end
  pitch("Les #{non_conformes.count} concurrents avec dossier non conforme ont reçu le bon mail")

  # Les membres du jury 1 ont reçu un mail informatif
  jures1 = TEvaluator.evaluators.select { |dc| dc[:jury] == 1 || dc[:jury] == 3 }
  jures2 = TEvaluator.evaluators.select { |dc| dc[:jury] == 2 }
  jures1.count > 0 || raise("Il devrait y avoir des membres du premier jury")
  jures2.count > 0 || raise("Il devrait y avoir des membres du second jury")

  jures1.each do |membre|
    expect(membre).to have_mail({after:start_time, subject:'Fin de l’échéance des dépôts', message:'avez maintenant un mois et demi pour procéder à la première sélection'})
  end
  pitch("Les #{jures1.count} membres du premier jury ont été informés par mail.")

  jures2.each do |membre|
    expect(membre).to have_mail({after:start_time, subject:'Fin de l’échéance des dépôts', message:'Les membres du premier jury vous procéder à la première sélection'})
  end
  pitch("Les #{jures2.count} membres du second jury ont été informés par mail.")

end #/ check_phase_2


# Avant de procéder au changement de phase, on s'assure d'avoir ce qu'il faut
def ensure_test_phase_2
  candidatures = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ?", [ANNEE_CONCOURS_COURANTE])

  if candidatures.count < 3
    raise "Il faudrait plus de 3 candidatures, pour pouvoir tester la phase 2…"
  end

  sans_dossier  = candidatures.select { |dc| dc[:specs][0]    == '0' }
  conformes     = candidatures.select { |dc| dc[:specs][0..1] == '11'}
  non_conformes = candidatures.select { |dc| dc[:specs][0..1] == '12'}

  if sans_dossier.empty?
    if conformes.count > 1
      concid = conformes.pop[:concurrent_id]
    else
      concid = non_conformes.pop[:concurrent_id]
    end
    conc = TConcurrent.get(concid)
    conc.destroy_dossier
  end

  if conformes.empty?
    raise "Il faudrait au moins une candidature avec dossier conforme, pour pouvoir bien checher."
  end
  if non_conformes.empty?
    if conformes.count > 1
      concid = conforms.pop[:concurrent_id]
    elsif sans_dossier.count > 1
      concid = sans_dossier.pop[:concurrent_id]
    else
      raise "Impossible de trouver une candidature pour un dossier non conforme…"
    end
    conc = TConcurrent.get(concid)
    conc = make_fichier_non_conforme
  end

  # On refait la vérification
  candidatures  = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ?", [ANNEE_CONCOURS_COURANTE])
  sans_dossier  = candidatures.select { |dc| dc[:specs][0]    == '0' }
  conformes     = candidatures.select { |dc| dc[:specs][0..1] == '11'}
  non_conformes = candidatures.select { |dc| dc[:specs][0..1] == '12'}

  (sans_dossier.count > 0 && conformes.count > 0 && non_conformes.count > 0) || begin
    raise "Je n'ai pas pu établir des dossiers non transmis, conformes et non conformes pour le test de la phase 2… Je dois renoncer."
  end
end #/ ensure_test_phase_2
