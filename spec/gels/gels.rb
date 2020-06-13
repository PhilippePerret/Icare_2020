# encoding: UTF-8
=begin
  Procédures de gels
=end
Dir['./spec/support/Gel/**/*.rb'].each{|m|require m}
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
    save_and_open_page
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
    login(mail: user_mail, password:data[:password][:value])
    save_and_open_page
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
    save_and_open_page
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
    save_and_open_page
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
    save_and_open_page
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
    save_and_open_page
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
      # Le premier document
      # attach_file('input[type="file"]', path_doc_comments)
      first('input[type="file"]').set(path_doc_comments)
      # Soumettre le formulaire
      click_on('Envoyer les commentaires')
    end
    save_and_open_page
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
    save_and_open_page('recupere-comments')
    logout
  end
end #/ recupere_comments

def get_icetape_user(idx)
  db_get('icetapes', get_icmodule_user(idx)[:icetape_id])
end #/ get_icetape_user
def get_icmodule_user(idx)
  db_get('icmodules', get_user_by_index(idx)[:icmodule_id])
end #/ get_icmodule_user

def get_user_by_index(idx)
  data = DATA_SPEC_SIGNUP_VALID[idx]
  user_mail = data[:mail][:value]
  db_get('users', {mail: user_mail})
end #/ get_user_by_index

def depot_qdd
  degel_or_gel('depot_qdd') do
    recupere_travail
    goto_login_form
    login_admin
    goto('admin/notifications')
    # On doit donner les documents commentés
    path_doc1_original = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.pdf')
    path_doc1_comments = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail_comsPhil.pdf')
    path_doc2_original = File.join(SPEC_FOLDER_DOCUMENTS, 'autre_doc.pdf')
    sleep 30
    within("form#sharing-form-etape-#{get_icetape_user(1)[:id]}") do
      attach_file("partage_1_original", path_doc1_original)
      attach_file("partage_1_comments", path_doc1_comments)
      attach_file("partage_2_original", path_doc2_original)
      click_on('Déposer ces documents'.freeze)
    end
    save_and_open_page('depot-qdd')
    logout
  end
end #/ depot_qdd

def define_sharing
  degel_or_gel('define_sharing') do
    depot_qdd
    goto_login_form
    login_icarien(1)
    goto('bureau/notifications')

    save_and_open_page('define-sharing')
    logout
  end
end #/ define_sharing
