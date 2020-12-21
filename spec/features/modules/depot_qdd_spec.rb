# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour checker le dépôt sur le QDD d'un document
=end
require_relative './_required'

feature "Dépôt sur le QDD" do
  before(:all) do
    degel('recupere_comments')
    require './_lib/_watchers_processus_/IcEtape/qdd_depot/constants'
    require './spec/support/optional_classes/TICModule'
  end

  scenario "Je peux déposer un document sur le QDD à partir de la notification" do

    # = Opération préparatoires =
    start_time = Time.now.to_i

    FOLDER_QDD = './_lib/data/qdd/1'
    FileUtils.rm_rf(FOLDER_QDD)

    # = Vérifications préliminaires +
    # Les options des documents sont correctes
    expect(marion.icetape.status).to eq(4)
    doc1 = db_exec("SELECT * FROM icdocuments WHERE id = 1")[0]
    expect(doc1).not_to eq(nil)
    expect(doc1[:options][3]).to eq('0')
    expect(doc1[:options][11]).to eq('0')
    doc2 = db_exec("SELECT * FROM icdocuments WHERE id = 2")[0]
    expect(doc2).not_to eq(nil)
    expect(doc2[:options][3]).to eq('0')
    expect(doc2[:options][11]).to eq('0')

    # Une notification existe pour des documents à déposer
    notify = db_exec("SELECT * FROM watchers WHERE wtype = ?", ["qdd_depot"])[0]
    # puts "notify: #{notify.inspect}"
    expect(notify).not_to eq(nil)

    # = Mise en place pour le test et pré-vérifications
    phil.rejoint_son_bureau
    phil.click_on('Notifications')
    expect(page).to have_titre('Notifications')
    expect(page).to have_css("div#watcher-#{notify[:id]}")
    expect(page).to have_css("form#qdd-depot-form-etape-#{notify[:objet_id]}")

    # ===> TEST <===
    # On prend les documents à déposer
    path_ori_work1 = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.pdf')
    path_com_work1 = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail_comsPhil.pdf')
    path_ori_work2 = File.join(SPEC_FOLDER_DOCUMENTS,'extrait.pdf')
    within("form#qdd-depot-form-etape-#{notify[:objet_id]}") do
      # On vérifie que les bons champs soient présents
      expect(page).to have_css('input[type="file"]#document-1-original')
      expect(page).to have_css('input[type="file"]#document-1-comments')
      expect(page).to have_css('input[type="file"]#document-2-original')
      expect(page).not_to have_css('input[type="file"]#document-2-comments')
      # On attache les fichiers à déposer
      attach_file("document-1-original", path_ori_work1)
      attach_file("document-1-comments", path_com_work1)
      attach_file("document-2-original", path_ori_work2)
      click_on("Déposer ces documents")
    end

    # = Vérifications post-opération =
    # sleep 4
    # Un message de confirmation est affiché
    expect(page).to have_message(MESSAGES[:qdd_confirm_depot])

    # Les documents se trouvent maintenant sur le QDD avec les bons noms
    noms = [
      'Analyse_etape_1_Marionm_1_original.pdf',
      'Analyse_etape_1_Marionm_1_comments.pdf',
      'Analyse_etape_1_Marionm_2_original.pdf'
    ]
    noms.each do |ndoc|
      expect(File).to be_exists(File.join(FOLDER_QDD,ndoc)),
        "Le fichier #{ndoc.inspect} devrait avoir été déposé sur le QdD"
    end

    # Les documents ne portent pas leur nom original mais un nom correctement
    # calculé
    badnames = ['document_travail.pdf','document_travail_comsPhil.pdf', 'extrait.pdf']
    badnames.each do |ndoc|
      expect(File).not_to be_exists(File.join(FOLDER_QDD,ndoc)),
        "Le fichier #{ndoc.inspect} ne devrait pas exister dans le QdD"
    end

    # Les données des documents ont été correctement marqués
    # bit 3 à 1 et bit 11 à 1 si commentaires (0 otherwise)
    doc1 = db_exec("SELECT * FROM icdocuments WHERE id = 1")[0]
    expect(doc1).not_to eq(nil)
    expect(doc1[:options][3]).to eq('1')
    expect(doc1[:options][11]).to eq('1')
    doc2 = db_exec("SELECT * FROM icdocuments WHERE id = 2")[0]
    expect(doc2).not_to eq(nil)
    expect(doc2[:options][3]).to eq('1')
    expect(doc2[:options][11]).to eq('0')

    # Des tickets ont été produits pour définir le partage des documents
    # TODO

    # L'étape est passé au statut 6
    marion.icetape.reset
    expect(marion.icetape.status).to eq(6)

    # L'icarien a reçu un mail l'invitant à définir le partage de ses
    # documents
    expect(marion).to have_mail(after:start_time, subject:MESSAGES[:subject_mail_user])

  end
end
