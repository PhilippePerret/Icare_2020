# encoding: UTF-8
=begin
  Procédures de gels
=end
require_gel
require_data('signup_data') # => DATA_SPEC_SIGNUP_VALID

include SpecModuleNavigation
include SpecModuleFormulaire

def inscription_marion
  degel_or_gel('inscription_marion') do
    def clic_signup_button
      find('#signup-btn').click
    end #/ clic_signup_button
    # Les données à tester
    data = DATA_SPEC_SIGNUP_VALID[1]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    save_screenshot('inscription_marion.htm')
  end
end #/ inscription_marion

def validation_mail
  degel_or_gel('validation_mail') do
    inscription_marion
    data = DATA_SPEC_SIGNUP_VALID[1]
    user_mail = data[:mail][:value]
    candidat = db_get('users', {mail: user_mail})
    dticket = db_get('tickets', {user_id: candidat[:id]})
    visit "#{SpecModuleNavigation::URL_OFFLINE}/bureau/home?tik=#{dticket[:id]}".freeze
    login_in_form(mail: user_mail, password:data[:password][:value])
    save_screenshot('validation_mail.png')
    logout # pour laisser la place à l'administrateur
  end
end #/ validation_mail

def validation_inscription
  degel_or_gel('validation_inscription') do
    validation_mail
    goto_login_form
    login_admin
    goto 'admin/notifications'
    within("#validation-candidature-form".freeze) do
      click_on('Attribuer ce module'.freeze)
    end
    save_screenshot('validation_inscription.png')
    logout
  end
end #/ admin_valide_inscription

def demarrage_module
  degel_or_gel('demarrage_module') do
    validation_inscription
    goto_login_form
    login_icarien(1)
    goto 'bureau/notifications'
    click_on('run-button-icmodule-start')
    save_screenshot('demarrage_module.png')
    logout
  end
end #/ marion_demarre_module

def envoi_travail
  degel_or_gel('envoi_travail') do
    demarrage_module
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
    save_screenshot('envoi_travail.png')
    logout
  end
end #/ marion_envoie_ses_documents

def recupere_travail
  degel_or_gel('recupere_travail') do
    envoi_travail
    goto_login_form
    login_admin
    goto('admin/notifications')
    click_on('Télécharger les documents')
    save_screenshot('recupere_travail.png')
    logout
  end
end #/ recupere_travail

def envoi_comments
  degel_or_gel('envoi_comments') do
    recupere_travail
    goto_login_form
    login_admin
    goto('admin/notifications')
    # On doit donner les documents commentés
    path_doc_comments  = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail_comsPhil.rtf')
    within("form#send-comments-form") do
      attach_file('document-1-comments', path_doc_comments)
      click_on('Envoyer les commentaires')
    end
    save_screenshot('envoi_comments.png')
    logout
  end
end #/ envoi_comments

def recupere_comments
  degel_or_gel('recupere_comments') do
    envoi_comments
    goto_login_form
    login_icarien(1)
    goto('bureau/home')
    click_on('Notifications')
    click_on('Télécharger les commentaires')
    save_screenshot('recupere-comments.png')
    logout
  end
end #/ recupere_comments

def change_etape
  degel_or_gel('change_etape') do
    recupere_comments
    goto_login_form
    login_admin
    goto('admin/notifications')
    click_on('Changer l’étape'.freeze)
    save_screenshot('change-etape.png')
    logout
  end
end #/ change_etape

def depot_qdd
  degel_or_gel('depot_qdd') do
    change_etape
    goto_login_form
    login_admin
    goto('admin/notifications')
    # On doit donner les documents commentés
    path_doc1_original = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.pdf')
    path_doc1_comments = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail_comsPhil.pdf')
    path_doc2_original = File.join(SPEC_FOLDER_DOCUMENTS, 'autre_doc.pdf')
    within("form#qdd-depot-form-etape-#{get_icetape_user(1)[:id]}") do
      attach_file("document-1-original", path_doc1_original)
      attach_file("document-1-comments", path_doc1_comments)
      attach_file("document-2-original", path_doc2_original)
      click_on('Déposer ces documents'.freeze)
    end
    save_screenshot('depot-qdd.png')
    logout
  end
end #/ depot_qdd

def define_sharing
  degel_or_gel('define_sharing') do
    depot_qdd
    goto_login_form
    login_icarien(1)
    goto('bureau/notifications')
    whithin("sharing-form-etape-1") do
      choose("1", from: "partage-1-original")
      choose("2", from: "partage-1-comments")
      choose("2", from: "partage-2-original")
      click_on('Appliquer ce partage'.freeze)
    end
    save_screenshot('define-sharing.png')
    logout
  end
end #/ define_sharing
