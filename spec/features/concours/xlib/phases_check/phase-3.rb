# encoding: UTF-8
# frozen_string_literal: true
=begin
  Check du bon déroulé de la phase _3

  Dans cette phase, notamment, doit être calculé le premier classement, avec
  les dix présélectionnés. Les autres concurrents sont "figés" à leur place.

=end

# Le test profond de la phase
def check_phase_3

  start_time = Time.now.to_i - 4

  # LE FICHIER PALMARÈS
  # -------------------
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
  expect(data_palmares).to have_key(:non_conformes)
  expect(data_palmares).to have_key(:sans_dossier)

  dinfos = data_palmares[:infos]
  expect(dinfos[:annee]).to eq(ANNEE_CONCOURS_COURANT)
  expect(dinfos[:nombre_inscriptions]).to eq(candidatures.count)
  expect(dinfos[:nombre_concurrents]).to eq(conformes.count)
  expect(dinfos[:nombre_sans_dossier]).to eq(sans_dossiers.count)
  expect(dinfos[:nombre_non_conforme]).to eq(non_conformes.count)

  # Vérification du classement
  Dossier.conformes.each do |dossier|
    expect(data_palmares[:classement][dossier.position - 1][:concurrent_id]).to eq(dossier.concurrent_id),
      "Le concurrent #{dossier.concurrent_id} devrait être à la position #{dossier.position}…"
  end


  # LES MAILS ENVOYÉS
  # -----------------
  pending "traiter les mails envoyés pour annoncer le premier classement"

  # Le mail doit contenir un lien conduisant à la présélection
  # TODO

  # Le mail doit être différent pour les présélectionnés
  # TODO

end


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
