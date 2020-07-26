# encoding: UTF-8
feature "Envoi des documents de travail" do
  before(:all) do
    require './_lib/pages/bureau/travail/constants'
    require './_lib/pages/bureau/sender/constants'
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
    scenario 'ne peut pas envoyer de documents' do
    end
  end


  context 'un icarien actif' do
    scenario 'peut envoyer ses documents de travail', only:true do
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

      # --- VÉRIFICATIONS ---
      # Enregistrement des fichiers physiques des documents
      # TODO
      # Création valide des instances icdocuments (associés à l'étape)
      # TODO
      # Envoi d'un message à l'administration
      # TODO
      # Création d'un notification (watcher) pour charger les documents
      # TODO
      # Changement du statut de l'étape courante
      # TODO

    end #/scénario envoi de trois documents par marion

  end
end
