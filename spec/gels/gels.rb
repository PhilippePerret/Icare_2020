# encoding: UTF-8
=begin
  Procédures de gels
=end
Dir['./spec/support/Gel/**/*.rb'].each{|m|require m}

def inscription_marion
  gel('inscription_marion').degel_or_gel do
    def clic_signup_button
      find('#signup-btn').click
    end #/ clic_signup_button
    # Les données à tester
    require_data('signup_data')
    data = DATA_SPEC_SIGNUP_VALID[1]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    save_and_open_page
  end
end #/ inscription_marion

def validation_mail
  gel('validation_mail').degel_or_gel do
    require_data('signup_data')
    data = DATA_SPEC_SIGNUP_VALID[1]
    user_mail = data[:mail][:value]
    candidat = db_get('users', {mail: user_mail})
    dticket = db_get('tickets', {user_id: candidat[:id]})
    visit "#{SpecModuleNavigation::URL_OFFLINE}/bureau/home?tik=#{dticket[:id]}".freeze
    login(mail: user_mail, password:data[:password][:value])
    save_and_open_page
    logout # pour laisser la place à l'administrateur
  end
end #/ validation_mail

def validation_inscription
  gel('validation_inscription').degel_or_gel do
    goto_login_form
    login_admin
    goto 'admin/notifications'
    within("#validation-candidature-form".freeze) do
      click_on('Attribuer ce module'.freeze)
    end
    save_and_open_page
    logout
  end
end #/ admin_valide_inscription

def demarrage_module
  gel('demarrage_module').degel_or_gel do
    goto_login_form
    login_icarien(1)
    goto 'bureau/notifications'
    click_on('run-button-icmodule-start')
    save_and_open_page
    logout
  end
end #/ marion_demarre_module

def envoi_travail
  gel('envoi_travail').degel_or_gel do
    goto_login_form
    login_icarien(1)
    goto 'bureau/sender?rid=send_work_form'
    path_doc_work   = File.join(SPEC_FOLDER_DOCUMENTS,'extrait.odt')
    path_doc_work2  = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.rtf')
    within("form#send-work-form") do
      # Le premier document
      attach_file('document-1', path_doc_work)
      sleep 1
      select("12", from: 'note-document1')
      # Le second document
      attach_file('document-3', path_doc_work2)
      sleep 1
      select("15", from: 'note-document3')
      # Soumettre le formulaire
      click_on(class: 'btn-send-work')
    end
    save_and_open_page
    logout
  end
end #/ marion_envoie_ses_documents

def recupere_travail
  degel('recupere_travail').or_gel do
    goto_login_form
    login_admin
    goto('admin/notifications')
    click_on('Télécharger les documents') # Il n'y en a qu'un seul pour le moment
    sleep 10
  end
end #/ recupere_travail
