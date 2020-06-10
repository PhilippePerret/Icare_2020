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
    # On boucle sur toutes les données à tester
    # Pour tester deux nouveaux candidats
    data = DATA_SPEC_SIGNUP_VALID[1]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    save_and_open_page
  end
end #/ inscription_marion

def validation_du_mail
  get('validation_du_mail').degel_if_exists || begin
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
end #/ validation_du_mail

def admin_valide_inscription
  gel('admin_valide_inscription').degel_if_exists || begin
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

def marion_demarre_module
  goto_login_form
  login_icarien(1)
  goto 'bureau/notifications'
  click_on('run-button-icmodule-start')
  save_and_open_page
  logout
end #/ marion_demarre_module

def marion_envoie_ses_documents
  goto_login_form
  login_icarien(1)
  goto 'bureau/sender?rid=send_work_form'
  path_doc_work = File.join(SPEC_FOLDER_DOCUMENTS,'extrait.odt')
  within("form#send-work-form") do
    attach_file('document-1', path_doc_work)
    sleep 1
    select("12", from: 'note-document1')
    click_on(class: 'btn-send-work')
  end
  save_and_open_page
  logout
end #/ marion_envoie_ses_documents
