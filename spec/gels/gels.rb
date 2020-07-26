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
    puts "Fabrication du gel 'inscription_marion'".vert
    def clic_signup_button
      find('#btn-signup').click
    end #/ clic_signup_button
    # Les données à tester
    data = DATA_SPEC_SIGNUP_VALID[1]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    screenshot('inscription_marion')
  end
end #/ inscription_marion

def validation_mail
  degel_or_gel('validation_mail') do
    inscription_marion
    puts "Fabrication du gel 'validation_mail'".vert
    data = DATA_SPEC_SIGNUP_VALID[1]
    user_mail = data[:mail][:value]
    candidat = db_get('users', {mail: user_mail})
    dticket = db_get('tickets', {user_id: candidat[:id]})
    visit "#{SpecModuleNavigation::URL_OFFLINE}/bureau/home?tik=#{dticket[:id]}".freeze
    login_in_form(mail: user_mail, password:data[:password][:value])
    screenshot('marion-valide-mail')
    logout # pour laisser la place à l'administrateur
  end
end #/ validation_mail

def validation_inscription
  degel_or_gel('validation_inscription') do
    validation_mail
    puts "Fabrication du gel 'validation_inscription'".vert
    login_admin
    goto 'admin/notifications'
    within("#validation-candidature-10-form".freeze) do
      click_on('Attribuer ce module'.freeze)
    end
    screenshot('validation_inscription')
    logout
  end
end #/ admin_valide_inscription

def demarrage_module
  degel_or_gel('demarrage_module') do
    validation_inscription
    puts "Fabrication du gel 'demarrage_module'".vert
    login_marion
    goto 'bureau/notifications'
    click_on('run-button-icmodule-start')
    screenshot('demarrage_module')
    logout
  end
end #/ marion_demarre_module

def envoi_travail
  degel_or_gel('envoi_travail') do
    demarrage_module
    puts "Fabrication du gel 'envoi_travail'".vert
    login_marion
    goto 'bureau/sender?rid=send_work_form'
    screenshot('sender-work-marion')
    path_doc_work   = File.join(SPEC_FOLDER_DOCUMENTS,'extrait.odt')
    path_doc_work2  = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.rtf')
    within("form#send-work-form") do
      # Le premier document
      attach_file('document1', path_doc_work)
      sleep 1
      select("12", from: 'note-document1')
      # Le second document
      attach_file('document3', path_doc_work2)
      sleep 1
      select("15", from: 'note-document3')
      # Soumettre le formulaire
      click_on(class: 'btn-send-work')
    end
    screenshot('envoi_travail')
    logout
  end
end #/ marion_envoie_ses_documents

def recupere_travail
  degel_or_gel('recupere_travail') do
    envoi_travail
    puts "Fabrication du gel 'recupere_travail'".vert
    login_admin
    goto('admin/notifications')
    click_on('Télécharger les documents')
    screenshot('recupere_travail')
    logout
  end
end #/ recupere_travail

def envoi_comments
  degel_or_gel('envoi_comments') do
    recupere_travail
    puts "Fabrication du gel 'envoi_comments'".vert
    login_admin
    goto('admin/notifications')
    # On doit donner les documents commentés
    path_doc_comments  = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail_comsPhil.rtf')
    within("form#send-comments-form") do
      attach_file('document1-comments', path_doc_comments)
      click_on('Envoyer les commentaires')
    end
    screenshot('envoi_comments')
    logout
  end
end #/ envoi_comments

def recupere_comments
  degel_or_gel('recupere_comments') do
    envoi_comments
    puts "Fabrication du gel 'recupere_comments'".vert
    goto_login_form
    login_icarien(1)
    goto('bureau/home')
    click_on('Notifications')
    click_on('Télécharger les commentaires')
    screenshot('recupere-comments')
    logout
  end
end #/ recupere_comments

def change_etape
  degel_or_gel('change_etape') do
    recupere_comments
    puts "Fabrication du gel 'change_etape'".vert
    login_admin
    goto('admin/notifications')
    click_on('Changer l’étape'.freeze)
    screenshot('change-etape')
    logout
  end
end #/ change_etape

def depot_qdd
  degel_or_gel('depot_qdd') do
    change_etape
    puts "Fabrication du gel 'depot_qdd'".vert
    login_admin
    goto('admin/notifications')
    # On doit donner les documents commentés
    path_doc1_original = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.pdf')
    path_doc1_comments = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail_comsPhil.pdf')
    path_doc2_original = File.join(SPEC_FOLDER_DOCUMENTS, 'autre_doc.pdf')
    within("form#qdd-depot-form-etape-1") do
      attach_file("document1-original", path_doc1_original)
      attach_file("document1-comments", path_doc1_comments)
      attach_file("document2-original", path_doc2_original)
      click_on('Déposer ces documents'.freeze)
    end
    screenshot('depot-qdd')
    logout
  end
end #/ depot_qdd

def define_sharing
  degel_or_gel('define_sharing') do
    require './_lib/_watchers_processus_/IcEtape/qdd_sharing/constants.rb'
    depot_qdd
    puts "Fabrication du gel 'define_sharing'".vert
    login_marion
    goto('bureau/notifications')
    within("form#sharing-form-etape-1") do
      select(DATA_SHARING[1][:name], from: "partage-1-original")
      select(DATA_SHARING[2][:name], from: "partage-1-comments")
      select(DATA_SHARING[2][:name], from: "partage-2-original")
      click_on('Appliquer ce partage'.freeze)
    end
    screenshot('marion-define-sharing-etape-1')
    logout
  end
end #/ define_sharing

def inscription_benoit
  degel_or_gel('inscription_benoit') do
    define_sharing
    puts "Fabrication du gel 'inscription_benoit'".vert
    Capybara.reset_sessions!
    def clic_signup_button
      find('#btn-signup').click
    end #/ clic_signup_button
    # Les données à tester
    data = DATA_SPEC_SIGNUP_VALID[2]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    screenshot('inscription-benoit')
  end
end #/ inscription_benoit

def inscription_elie
  degel_or_gel('inscription_elie') do
    inscription_benoit
    puts "Fabrication du gel 'inscription_elie'".vert
    Capybara.reset_sessions!
    def clic_signup_button
      find('#btn-signup').click
    end #/ clic_signup_button
    # Les données à tester
    data = DATA_SPEC_SIGNUP_VALID[3]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    screenshot('inscription_elie')
  end
end #/ inscription_benoit

def benoit_valide_son_mail
  degel_or_gel('benoit_valide_son_mail') do
    inscription_elie
    puts "Fabrication du gel 'benoit_valide_son_mail'".vert
    Capybara.reset_sessions!
    data = DATA_SPEC_SIGNUP_VALID[2]
    user_mail = data[:mail][:value]
    candidat  = db_get('users', {mail: user_mail})
    dticket   = db_get('tickets', {user_id: candidat[:id]})
    visit "#{SpecModuleNavigation::URL_OFFLINE}/bureau/home?tik=#{dticket[:id]}".freeze
    login_in_form(mail: user_mail, password:data[:password][:value])
    screenshot('benoit-valide-son-mail')
    logout # pour laisser la place à l'administrateur
  end
end #/ benoit_valide_son_mail

def elie_valide_son_mail
  degel_or_gel('elie_valide_son_mail') do
    benoit_valide_son_mail
    puts "Fabrication du gel 'elie_valide_son_mail'".vert
    Capybara.reset_sessions!
    data = DATA_SPEC_SIGNUP_VALID[3]
    user_mail = data[:mail][:value]
    candidat  = db_get('users', {mail: user_mail})
    dticket   = db_get('tickets', {user_id: candidat[:id]})
    visit "#{SpecModuleNavigation::URL_OFFLINE}/bureau/home?tik=#{dticket[:id]}".freeze
    login_in_form(mail: user_mail, password:data[:password][:value])
    screenshot('elie-valide-son-mail')
    logout # pour laisser la place à l'administrateur
  end
end #/ elie_valide_son_mail

def validation_deux_inscriptions
  degel_or_gel('validation_deux_inscriptions') do
    elie_valide_son_mail
    puts "Fabrication du gel 'validation_deux_inscriptions'".vert
    Capybara.reset_sessions!
    login_admin
    goto 'admin/notifications'
    within("#validation-candidature-12-form".freeze) do
      select('Suivi de projet (intensif)'.freeze, from: 'module_id-12')
      click_on('Attribuer ce module'.freeze)
    end
    within("#validation-candidature-11-form".freeze) do
      select('Personnages'.freeze, from: 'module_id-11')
      click_on('Attribuer ce module'.freeze)
    end
    screenshot('valide-signup-elie-benoit')
    logout
  end
end #/validation_deux_inscriptions

def benoit_frigote_phil_marion_et_elie
  degel_or_gel('benoit_frigote_phil_marion_et_elie') do
    validation_deux_inscriptions
    puts "Fabrication du gel 'benoit_frigote_phil_marion_et_elie'".vert
    Capybara.reset_sessions!
    goto_login_form
    login_icarien(2)
    click_on("Bureau")
    click_on("Porte de frigo")
    click_on("les autres icarien·ne·s")
    within("#icarien-10") do
      click_on('message sur son frigo')
    end
    within('#frigo-discussion-form') do
      fill_in('frigo_titre', with: "Titre discussion avec Marion".freeze)
      fill_in('frigo_message', with: "Hello Marion, est-ce qu'on peut parler ?".freeze)
      click_on("Poser ce message sur le frigo de Marion")
    end
    click_on('Votre frigo') # pour revenir sur le frigo
    click_on("les autres icarien·ne·s")
    within("#icarien-12") do
      click_on('message sur son frigo')
    end
    within('#frigo-discussion-form') do
      fill_in('frigo_titre', with: "Titre discussion avec Élie".freeze)
      fill_in('frigo_message', with: "Hello Élie, est-ce qu'on peut parler ?".freeze)
      click_on("Poser ce message sur le frigo de Élie")
    end
    click_on('Votre frigo') # pour revenir sur le frigo
    # Benoit, sur son bureau, section frigo, initie une conversation
    # avec Phil.
    within('#discussion-phil-form') do
      fill_in('frigo_titre', with: "Titre discussion avec Phil".freeze)
      fill_in('frigo_message', with: "Hello Phil, est-ce qu'on peut parler ?".freeze)
      click_on("Lancer la discussion avec Phil")
    end
    logout # pour laisser la place
  end
end #/ benoit_frigote_phil_marion_et_elie


def phil_marion_elie_repondent_benoit
  # Après ce test, Benoit a trois réponses à ses trois discussions
  degel_or_gel('phil_marion_elie_repondent_benoit') do
    benoit_frigote_phil_marion_et_elie
    puts "Fabrication du gel 'phil_marion_elie_repondent_benoit'".vert
    require './_lib/modules/frigo/constants' # (messages et erreurs)
    # Phil répond au message
    Capybara.reset_sessions!
    # Phil répond au message
    login_admin
    click_on('Bureau')
    click_on('Porte de frigo')
    click_on('Titre discussion avec Phil')
    within('form#discussion-form') do
      fill_in('frigo_message', with: "La réponse de Phil au message de Benoit.")
      click_on("Ajouter")
    end
    screenshot('phil-repond-message-benoit')
    logout

    # Marion répond au message
    Capybara.reset_sessions!
    login_marion
    click_on('Bureau')
    click_on('Porte de frigo')
    click_on('Titre discussion avec Marion')
    within('form#discussion-form') do
      fill_in('frigo_message', with: "Marion répond qu'elle veut bien discuter.")
      click_on("Ajouter")
    end
    screenshot('marion-repond-message-benoit')
    logout

    # Élie répond au message (note : il va laisser deux messages)
    Capybara.reset_sessions!
    login_elie
    click_on('Bureau')
    click_on('Porte de frigo')
    click_on('Titre discussion avec Élie')
    within('form#discussion-form') do
      fill_in('frigo_message', with: "Réponse d’Élie à Benoit.")
      click_on("Ajouter")
    end
    message_benoit = MESSAGES[:follower_warned_for_new_message] % 'Benoit'
    screenshot('elie-premier-message-benoit')
    expect(page).not_to have_content(message_benoit),
      "Élie ne devrait pas avoir de message lui disant que Benoit a été averti. Benoit a déjà un message non lu pour ce fil."

    # Élie laisse un second message
    within('form#discussion-form') do
      fill_in('frigo_message', with: "Une autre réponse d’Élie à Benoit.")
      click_on("Ajouter")
    end
    screenshot('elie-second-message-benoit')
    expect(page).not_to have_content(message_benoit)

    logout
  end
end #/ phil_marion_elie_repondent_benoit

def inscription_destroyed
  degel_or_gel('inscription_destroyed') do
    phil_marion_elie_repondent_benoit
    puts "Fabrication du gel 'inscription_destroyed'".vert
    Capybara.reset_sessions!
    def clic_signup_button
      find('#btn-signup').click
    end #/ clic_signup_button
    # Les données à tester
    data = DATA_SPEC_SIGNUP_VALID[4]
    goto_home
    clic_signup_button
    fill_formulaire_with('#signup-form', data)
    submit_formulaire('#signup-form')
    screenshot('inscription_destroyed')
  end
end #/ inscription_destroyed

def destroyed_valide_son_mail
  degel_or_gel('destroyed_valide_son_mail') do
    inscription_destroyed
    puts "Fabrication du gel 'destroyed_valide_son_mail'".vert
    Capybara.reset_sessions!
    data = DATA_SPEC_SIGNUP_VALID[4]
    user_mail = data[:mail][:value]
    candidat  = db_get('users', {mail: user_mail})
    dticket   = db_get('tickets', {user_id: candidat[:id]})
    visit "#{SpecModuleNavigation::URL_OFFLINE}/bureau/home?tik=#{dticket[:id]}".freeze
    login_in_form(mail: user_mail, password:data[:password][:value])
    screenshot('detruit_valide-son-mail')
    logout # pour laisser la place à l'administrateur
  end
end #/ destroyed_valide_son_mail

def phil_valide_inscription_destroyed
  degel_or_gel('phil_valide_inscription_destroyed') do
    destroyed_valide_son_mail
    puts "Fabrication du gel 'phil_valide_inscription_destroyed'".vert
    Capybara.reset_sessions!
    login_admin
    goto 'admin/notifications'
    within("#validation-candidature-13-form".freeze) do
      select('Analyse de film'.freeze, from: 'module_id-13')
      click_on('Attribuer ce module'.freeze)
    end
    screenshot('phil-valide-signup-destroyed')
    logout
  end
end #/phil_valide_inscription_destroyed

def destroyed_demarre_son_module
  degel_or_gel('destroyed_demarre_son_module') do
    phil_valide_inscription_destroyed
    puts "Fabrication du gel 'destroyed_demarre_son_module'".vert
    Capybara.reset_sessions!
    login_destroyed
    goto 'bureau/notifications'
    click_on('run-button-icmodule-start')
    screenshot('destroyed_demarre_son_module')
    logout
  end
end #/ destroyed_demarre_son_module

def destroyed_se_detruit
  degel_or_gel('destroyed_se_detruit') do
    destroyed_demarre_son_module
    puts "Fabrication du gel 'destroyed_se_detruit'".vert
    Capybara.reset_sessions!
    login_destroyed
    click_on 'Bureau'
    click_on 'Profil'
    click_on 'Détruire le profil'
    data_user = DATA_SPEC_SIGNUP_VALID[4]
    within('form#destroy-user-form') do
      fill_in('user_password', with: data_user[:password][:value])
      click_on 'Détruire définitivement mon profil'
    end
    screenshot('destroyed_se_detruit')
  end
end #/ destroyed_se_detruit

# Démarrage des modules pour Élie et Benoit
def elie_demarre_son_module
  degel_or_gel('elie_demarre_son_module') do
    destroyed_se_detruit
    puts "Fabrication du gel 'elie_demarre_son_module'".vert
    Capybara.reset_sessions!
    login_elie
    goto 'bureau/notifications'
    click_on('run-button-icmodule-start')
    screenshot('elie_demarre_son_module')
    logout
  end
end #/ elie_demarre_son_module
def benoit_demarre_son_module
  degel_or_gel('benoit_demarre_son_module') do
    elie_demarre_son_module
    puts "Fabrication du gel 'benoit_demarre_son_module'".vert
    Capybara.reset_sessions!
    login_benoit
    goto 'bureau/notifications'
    click_on('run-button-icmodule-start')
    screenshot('benoit_demarre_son_module')
    logout
  end
end #/ benoit_demarre_son_module



def marion_envoie_deux_autres_documents_cycle_complet
  degel_or_gel('marion_envoie_deux_autres_documents_cycle_complet') do
    benoit_demarre_son_module
    puts "Fabrication du gel 'marion_envoie_deux_autres_documents_cycle_complet'".vert
    login_marion
    goto 'bureau/sender?rid=send_work_form'
    path_doc_work   = File.join(SPEC_FOLDER_DOCUMENTS,'doc_travail_final.odt')
    path_doc_work2  = File.join(SPEC_FOLDER_DOCUMENTS,'doc_travail_final2.odt')
    within("form#send-work-form") do
      # Le premier document
      attach_file('document1', path_doc_work)
      sleep 1
      # sleep 30
      select("8/20", from: 'note-document1')
      # Le second document
      attach_file('document2', path_doc_work2)
      sleep 1
      select("11/20", from: 'note-document2')
      # Soumettre le formulaire
      click_on(class: 'btn-send-work')
    end
    screenshot('marion-envoie-second-travail')
    logout

    phil.rejoint_ses_notifications
    click_on('Télécharger les documents')
    logout

    # Je reviens donner les commentaires
    login_admin
    goto('admin/notifications')
    # On doit donner les documents commentés
    path_doc_comments  = File.join(SPEC_FOLDER_DOCUMENTS,'final1_comsPhil.pdf')
    path_doc_comments2 = File.join(SPEC_FOLDER_DOCUMENTS,'final2_comsPhil.pdf')
    within("form#send-comments-form") do
      attach_file('document3-comments', path_doc_comments)
      attach_file('document4-comments', path_doc_comments)
      click_on('Envoyer les commentaires')
    end
    screenshot('phil-envoie-seconds-commentaires-a-marion')
    logout

    marion.rejoint_ses_notifications
    click_on('Télécharger les commentaires')
    screenshot('marion-gets-ses-seconds-commentaires')
    logout

    phil.rejoint_ses_notifications
    click_on('Changer l’étape'.freeze)
    screenshot('Phil-change-etape-de-Marion')
    logout


    phil.rejoint_ses_notifications
    # On doit donner les documents commentés
    path_doc1_original = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail.pdf')
    path_doc1_comments = File.join(SPEC_FOLDER_DOCUMENTS,'document_travail_comsPhil.pdf')
    path_doc2_original = File.join(SPEC_FOLDER_DOCUMENTS, 'final1_comsPhil.pdf')
    path_doc2_comments = File.join(SPEC_FOLDER_DOCUMENTS, 'final2_comsPhil.pdf')
    within("form#qdd-depot-form-etape-2") do
      attach_file("document3-original", path_doc1_original)
      attach_file("document3-comments", path_doc1_comments)
      attach_file("document4-original", path_doc2_original)
      attach_file("document4-comments", path_doc2_original)
      click_on('Déposer ces documents'.freeze)
    end
    screenshot('depot-qdd')
    logout

    require './_lib/_watchers_processus_/IcEtape/qdd_sharing/constants.rb'
    marion.rejoint_ses_notifications
    within("form#sharing-form-etape-2") do
      select(DATA_SHARING[1][:name], from: "partage-3-original")
      select(DATA_SHARING[1][:name], from: "partage-3-comments")
      select(DATA_SHARING[1][:name], from: "partage-4-original")
      select(DATA_SHARING[1][:name], from: "partage-4-comments")
      click_on('Appliquer ce partage'.freeze)
    end
    screenshot('marion-partage-tout-ses-seconds-documents')
    logout
  end
end #/ marion_envoie_deux_autres_documents_cycle_complet


# Réponse de 2 icariens aux messages frigo
# TODO
#
# Invitation d'un icarien à rejoindre une discussion
# TODO
#
# Paiement d'un module (par PayPal)
# TODO
#
# Paiement d'un module (par IBAN
# TODO)
