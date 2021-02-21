# encoding: UTF-8
# frozen_string_literal: true
=begin
  Check du bon déroulé de la phase _3

  Dans cette phase, notamment, doit être calculé le premier classement, avec
  les dix présélectionnés. Les autres concurrents sont "figés" à leur place.

  C'est dans cette phase aussi qu'on construit le fichier HTML du tableau
  des palmarès.

=end

# Le test profond de la phase
def check_phase_3

  start_time = Time.now.to_i - 4

  # LE FICHIER DES DONNÉES (PALMARÈS)
  # ---------------------------------
  # Il faut vérifier que le fichier des résultats a bien été produit
  # C'est le fichier qui contient les classements et qui permet de faire
  # la page des palmarès.
  # Dans cette phase 3, il classe tous les concurrents, mais les dix premiers
  # sont encore en lice pour les prix finaux et sont donc susceptibles de
  # bouger dans cette liste.

  require './_lib/_pages_/concours/xmodules/calculs/Dossier'

  # Est-ce que le fichier des palmarès existe ?
  palmares_path = Dossier.palmares_file_path(ANNEE_CONCOURS_COURANTE).freeze
  expect(File).to be_exists(palmares_path), "le fichier des résultats (#{File.basename(palmares_path)}) devrait exister"

  # Est-ce que le fichier des palmarès contient les bonnes informations ?
  # ---------------------------------------------------------------------
  data_palmares = YAML.load_file(palmares_path)
  candidatures  = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ?", [ANNEE_CONCOURS_COURANTE])
  sans_dossiers = candidatures.select { |dc| dc[:specs][0]    == '0' }
  conformes     = candidatures.select { |dc| dc[:specs][0..1] == '11'}
  non_conformes = candidatures.select { |dc| dc[:specs][0..1] == '12'}

  # = Calcul du classement =

  # = Vérification du contenu du fichier palmarès =

  expect(data_palmares).to have_key(:infos)
  expect(data_palmares).to have_key(:classement)
  expect(data_palmares).to have_key(:non_conforme)
  expect(data_palmares).to have_key(:sans_dossier)

  dinfos = data_palmares[:infos]
  expect(dinfos[:annee]).to eq(ANNEE_CONCOURS_COURANTE)
  expect(dinfos[:nombre_inscriptions]).to eq(candidatures.count)
  expect(dinfos[:nombre_concurrents]).to eq(conformes.count)
  expect(dinfos[:nombre_sans_dossier]).to eq(sans_dossiers.count)
  expect(dinfos[:nombre_non_conforme]).to eq(non_conformes.count)

  # Vérification du classement
  Dossier.conformes.each do |dossier|
    # puts "dossier.position: #{dossier.position.inspect} (#{dossier.note_totale})"
    dpalm = data_palmares[:classement][dossier.position - 1]
    expect(dpalm[:concurrent_id]).to eq(dossier.concurrent_id),
      "Le concurrent #{dossier.concurrent_id} devrait être à la position #{dossier.position}…"
    expect(dpalm[:note]).to eq(dossier.note_totale),
      "La note consignée devrait valoir #{dossier.note_totale}, elle vaut #{dpalm[:note]}"
    expect(dpalm[:note]).not_to eq('NC'), "La note consignée ne devrait pas valoir 'NC'…"
  end


  # LE TABLEAU DES PRÉSÉLECTIONNÉS
  # ------------------------------
  # Dans la section "Palmarès", on doit pouvoir trouver la liste des présélec-
  # tionnés et des non présélectionnés
  fpath = File.join(CONCOURS_PALM_FOLDER,ANNEE_CONCOURS_COURANTE.to_s,"preselections.html")
  expect(File).to be_exists(fpath), "le fichier des présélections pour la section “Palmarès” du site devrait exister"
  pitch("Le tableau des présélectionnés et non retenus a été construit")


  # LES MAILS ENVOYÉS
  # -----------------

  nombre_femmes = conformes.select do |conc|
    TConcurrent.get(conc[:concurrent_id]).fille?
  end.count
  nombre_hommes = conformes.count - nombre_femmes

  # Tous les segments message commun à tous les destinataires, concurrents
  # présélectionnés, non retenus, jurés et admins
  segments_communs = [
    'http://localhost/AlwaysData/Icare_2020/concours/palmares',
    'présélections',
    /Concours de Synopsis de l'atelier Icare/i
  ]

  expect(Dossier.preselecteds.count).to eq(10)
  Dossier.preselecteds.each do |dossier|
    conc = TConcurrent.get(dossier.concurrent_id)
    expect(conc).to have_mail(after: start_time, subject: 'Bravo pour votre présélection',
    message: segments_communs + [
      'Bravo à vous !'
    ])
  end
  pitch("Un message a été envoyé aux 10 présélectionnés")

  Dossier.non_preselecteds.each do |dossier|
    conc = TConcurrent.get(dossier.concurrent_id)
    expect(conc).to have_mail(after: start_time, subject:'Fin des présélections',
    message: segments_communs + [
      'malheureusement', 'regrets sincères'
    ])
  end
  pitch("Un message de regret a été envoyé aux non présélectionnés")


  Dossier.sans_dossiers.each do |dossier|
    conc = TConcurrent.get(dossier.concurrent_id)
    expect(conc).to have_mail(after: start_time, subject:'Fin des présélections',
    message: segments_communs + [
      'malheureusement', 'pas été envoyé à temps ou jugé non conforme'
    ])
  end
  pitch("Un message de regret a été envoyé aux candidats sans dossier")


  TEvaluator.premiers_jures.each do |jure|
    expect(jure).to have_mail(after: start_time, subject: 'Fin des présélections',
    message: segments_communs + [
      'vous remercier'
    ])
  end
  pitch("Un message a été envoyé aux jurés du premier jury pour les remercier")

  TEvaluator.seconds_jures.each do |jure|
    expect(jure).to have_mail(after: start_time, subject:'Fin des présélections',
    message: segments_communs + [
      'procéder à la sélection des 3 lauréats parmi les 10 dossiers présélectionnés',
    ])
  end
  pitch("Un message a été envoyé aux jurés du second jury pour lancer la sélection finale")

end

def pluriels(nb)
  nb = nb.count if not nb.is_a?(Integer)
  plus = nb > 1
  {
    s: plus ? 's' : '',
    ont: plus ? 'ont' : 'a',
    sont: plus ? 'sont' : 'est',
    leur: plus ? 'leur' : 'son'
  }
end #/ pluriels

# Avant de procéder au changement de phase, on s'assure d'avoir ce qu'il faut
def ensure_test_phase_3
  candidatures = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ?", [ANNEE_CONCOURS_COURANTE])

  if candidatures.count < 20
    # Il faut au moins 15 candidatures pour pouvoir avoir des candidats non
    # préselectionnés
    (20 - candidatures.count).times do |itime|
      TConcurrent::Factory.create(current: true)
    end
    candidatures = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE annee = ?", [ANNEE_CONCOURS_COURANTE])
    if candidatures.count < 20
      raise "Il faudrait plus de 15 candidatures, pour pouvoir tester la phase 2…"
    end
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

end
