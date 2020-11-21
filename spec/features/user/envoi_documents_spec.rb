# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'
require './spec/support/optional_classes/TDocuments'

feature "Envoi des documents de travail" do
  before(:all) do
    require "#{FOLD_REL_PAGES}/bureau/travail/constants"
    require "#{FOLD_REL_PAGES}/bureau/sender/constants"
  end

  context 'un visiteur quelconque' do
    scenario 'ne peut pas envoyer de documents' do
      goto('bureau/sender?rid=send_work_form')
      expect(page).not_to have_titre('Envoi des documents de travail')
      expect(page).to have_titre('Identification')
    end
  end




  context 'un candidat à l’atelier icare' do
    scenario 'ne peut pas forcer l’envoi de documents' do
      degel('inscription_benoit')
      pitch("Benoit, tout juste inscrit, ne peut pas trouver un bouton pour remettre le travail sur son travail courant.")
      benoit.rejoint_le_site
      find('section#header').click
      click_on('Bureau')
      click_on('Travail courant')
      screenshot('candidat-dans-travail-courant')
      expect(page).not_to have_link(UI_TEXTS[:btn_remettre_travail])
      pitch("Benoit ne peut pas non plus rejoindre cette section en jouant directement l'URL")
      goto('bureau/sender?rid=send_work_form')
      screenshot('candidat-force-envoi-documents')
      expect(page).not_to have_titre('Envoi des documents de travail')
      expect(page).to have_message("vous ne pouvez donc pas envoyer de document")
    end
  end

  context 'un icarien inactif' do
    before :all do
      degel "real-icare"
      @icarien = TUser.get_random(status: :inactif, femme: true)
    end
    let(:icarien) { @icarien }
    scenario 'ne peut pas envoyer de documents' do
      # headless false
      icarien.rejoint_le_site
      find('section#header').click
      click_on('Bureau')
      click_on('Travail courant')
      screenshot('inactif-dans-travail-courant')
      expect(page).not_to have_link(UI_TEXTS[:btn_remettre_travail])
      expect(page).to have_content(/vous n’êtes pas en activité/i)
      # Il essaie de se rendre de force sur la page d'envoi
      goto("bureau/sender")
      expect(page).not_to have_css('form#send-work-form')
      expect(page).to have_message(/vous ne pouvez donc pas envoyer de documents/i)
      expect(page).to have_route("bureau/home")
    end
  end


  context 'un icarien actif' do
    scenario 'peut envoyer ses documents de travail' do
      degel('demarrage_module')
      pitch("Marion, après le démarrage de son module, peut rejoindre la section qui lui permet d'envoyer ses documents. Elle trouve un formulaire conforme et peut envoyer ses documents.")
      marion.rejoint_son_bureau
      click_on('Travail courant')
      click_on(UI_TEXTS[:btn_remettre_travail])
      screenshot('marion-active-rejoint-envoi-travail')
      expect(page).to have_titre('Envoi des documents de travail')
      expect(page).to have_css('form#send-work-form')
      within('form#send-work-form') do
        expect(page).to have_css('input[type="file"]', count: 5)
        # Le bouton pour transmettre les documents sera visible seulement lorsque
        # l'on a choisi un premier document.
        expect(page).not_to have_button(UI_TEXTS[:btn_transmettre_documents])
      end

      start_time = Time.now.to_i

      # Les trois documents à transmettre
      path_doc_work1 = File.join(SPEC_FOLDER_DOCUMENTS,'extrait.odt')
      path_doc_work2 = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.rtf')
      path_doc_work3 = File.join(SPEC_FOLDER_DOCUMENTS,'doc_travail_final2.odt')
      # Marion donne deux documents
      within('form#send-work-form') do
        # click_on('Choisir le document 1…')
        # sleep 2
        # puts "+++ page.driver.browser methods: #{page.driver.browser.methods.inspect}"
        # puts "+++ page.driver.browser.window_handles: #{page.driver.browser.window_handles.inspect}"
        # puts "+++ page.driver.browser.window_handle: #{page.driver.browser.window_handle.inspect}"
        # page.driver.browser.switch_to.window(page.driver.browser.window_handle).dismiss
        # sleep 2
        # puts "+++ page.driver.browser.switch_to.window: #{page.driver.browser.switch_to.window(:front).methods.inspect}"
        # raise('pour voir')
        # click_on('Choisir le document 2…')
        # click_on('Choisir le document 3…')
        attach_file('document1', path_doc_work1)
        sleep 1
        select("13", from: 'note-document1')
        attach_file('document2', path_doc_work2)
        sleep 1
        select("14", from: 'note-document2')
        attach_file('document3', path_doc_work3)
        sleep 1
        select("14", from: 'note-document3')
        expect(page).to have_button(UI_TEXTS[:btn_transmettre_documents])
        click_on(UI_TEXTS[:btn_transmettre_documents])
      end
      screenshot('marion-envoie-trois-documents-travail')

      marion.reset

      # --- VÉRIFICATIONS ---
      # Enregistrement des fichiers physiques des documents
      # TODO

      # Création valide des instances icdocuments (associés à l'étape)
      (1..3).each do |idoc|
        oname = File.basename(eval("path_doc_work#{idoc}"))
        expect(marion).to have_document(after: start_time, icetape_id: marion.icetape.id, original_name: oname)
      end

      # Envoi d'un message à l'administration
      expect(phil).to have_mail(after: start_time, subject: MESSAGES[:subject_mail_envoi_documents])
      # Envoi de confirmation de documents reçus
      expect(marion).to have_mail(after: start_time, subject: MESSAGES[:subject_mail_document_recus] % {s: "s"})

      # Création d'un notification (watcher) pour charger les documents
      expect(marion).to have_watcher(wtype: 'download_work', after: start_time),
        "Marion devrait avoir un watcher download-work"

      # Changement du statut de l'étape courante
      expect(marion.icetape.status).to eq(2),
        "Le statut de l'étape de Marion devrait être à 2"

      # Actualité pour annoncer l'envoi des documents
      expect(TActualites).to have_actualite(after: start_time, type: 'SENDWORK', user_id: marion.id),
        "Une actualité devrait annoncer l'envoi de documents"

    end #/scénario envoi de trois documents par marion

  end
end
