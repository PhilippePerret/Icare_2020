# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de mailing-list
  Quand l'administrateur est connecté, le formulaire de contact fonctionne
  comme un mailing list.
=end
require_relative './_required'

def mailing_json_path
  @mailing_json_path ||= File.join(MAILS_FOLDER,'mailing.json')
end #/ mailing_json_path

def unicarien
  @unicarien ||= begin
    TUser.get(30)
  end
end #/ unicarien

BTN_PROCEED_ENVOI_MAILING = "Procéder à l’envoi du mailing enregistré"
BTN_DESTROY_ENVOI_MAILING = "Détruire ce mailing"

feature 'Mailing-list d’administration' do

  before(:all) do
    require './_lib/_pages_/contact/mail/constants'
    require './_lib/modules/mail/constants'
    degel('real-icare') # Pour avoir beaucoup d'icariens
  end


  context 'Un utilisateur quelconque' do
    before(:each) do
      File.open(mailing_json_path,'wb'){|f| f.write('{"uuid":"DGFTY456DFG"}')}
    end
    after(:each) do
      File.delete(mailing_json_path)
    end

    scenario 'ne peut pas utiliser le mailing-list pour envoyer des messages' do
      expect(File.exists?(mailing_json_path)).to eq(true)
      goto('contact/mail')
      expect(page).not_to have_link(BTN_PROCEED_ENVOI_MAILING)
      goto('contact/mail?op=traite_mailing_list')
      expect(page).to have_titre('Identification')
      expect(File.exists?(mailing_json_path)).to eq(true)
    end

    scenario 'ne peut pas détruire un mailing-list enregistré' do
      expect(File.exists?(mailing_json_path)).to eq(true)
      goto('contact/mail')
      expect(page).not_to have_link(BTN_DESTROY_ENVOI_MAILING)
      goto('contact/mail?op=detruire_mailing_list?uuid=pourrire')
      expect(File.exists?(mailing_json_path)).to eq(true)
    end

  end




  context 'Un icarien identifié' do
    before(:each) do
      File.open(mailing_json_path,'wb'){|f| f.write('{"uuid":"DGFTY456DFG"}')}
    end
    after(:each) do
      File.delete(mailing_json_path)
    end

    scenario 'ne peut pas utiliser le mailing-list pour envoyer des messages' do

      expect(File.exists?(mailing_json_path)).to eq(true)
      unicarien.rejoint_son_bureau
      goto('contact/mail')
      expect(page).not_to have_link(BTN_PROCEED_ENVOI_MAILING)
      goto('contact/mail?op=traite_mailing_list')
      expect(page).to have_titre('Accès interdit')
      expect(File.exists?(mailing_json_path)).to eq(true)
    end

    scenario 'ne peut pas détruire un mailing-list enregistré' do
      expect(File.exists?(mailing_json_path)).to eq(true)
      unicarien.rejoint_le_site
      unicarien.rejoint_son_bureau
      goto('contact/mail')
      expect(page).not_to have_link(BTN_DESTROY_ENVOI_MAILING)
      goto('contact/mail?op=detruire_mailing_list?uuid=pourrire')
      expect(File.exists?(mailing_json_path)).to eq(true)
    end
  end




  context 'Un administrateur' do

    scenario 'peut envoyer des messages par le formulaire de contact' do

      # Avant toute chose, on s'assure qu'il n'existe pas un mailing
      # enregistré
      File.delete(mailing_json_path) if File.exists?(mailing_json_path)

      phil.rejoint_le_site
      phil.click('contact', within: '#footer')

      pitch("Je rejoins le site, m'identifie et rejoint le formulaire de contact.")
      expect(page).to have_titre("Mailing-list")

      # *** Vérifications préliminaires ***

      pitch("Je trouve un formulaire valide, avec des choix pour caractériser l'envoi")
      expect(page).to have_css('form#contact-form')
      expect(page).to have_css('div#div-statuts')
      expect(page).to have_css('select#message_format')
      expect(page).to have_css('select#mail_signature')
      expect(page).to have_button(UI_TEXTS[:btn_apercu])

      start_time = Time.now.to_i

      # *** Test
      pitch("Je peux rédiger un mail et en voir l'aspect, avec indication des icariens qui le recevront.")
      msg_sujet = "Sujet du #{formate_date}"
      msg_message  = "<p><%= pseudo %>,</p><p>C'est un message de mailing</p>"

      # JE NE SAIS PAS POURQUOI ÇA FOIRE, AVEC LA LIGNE CI-DESSOUS
      # within('#contact-form') do

      expect(page).to have_css('input#envoi_titre')
      fill_in 'envoi_titre', with: msg_sujet
      expect(page).to have_css('textarea#envoi_message')
      fill_in 'envoi_message', with: msg_message
      expect(page).to have_css('input#cb-statut-pause')
      check('cb-statut-pause')
      check('cb-statut-inactif')
      expect(page).to have_css('select#message_format')
      select('Erb', from: 'message_format')
      click_button(UI_TEXTS[:btn_apercu])

      # *** Vérification ***

      expect(page).to have_css('fieldset#mail-version-femme')
      expect(find('fieldset#mail-version-femme')).to have_content msg_sujet
      expect(page).to have_css('fieldset#mail-version-homme')
      expect(find('fieldset#mail-version-homme')).to have_content msg_sujet
      # On récupère les icariens en pause
      users_pause = db_exec("SELECT id, pseudo, mail FROM users WHERE SUBSTRING(options,17,1) = '8'")
      users_pause << {id:phil.id, pseudo:phil.pseudo, mail:phil.mail}

      within('fieldset#liste-destinataires') do
        users_pause.each do |udata|
          expect(page).to have_content(udata[:pseudo])
        end
      end

      # *** On procède à l'envoi ***

      pitch("Je trouve un bouton pour '#{UI_TEXTS[:proceed_envoi]}' pour envoyer le courier. Et je l'envoie.")
      expect(page).to have_link(UI_TEXTS[:proceed_envoi])
      click_link(UI_TEXTS[:proceed_envoi])

      # *** Vérifications ***

      users_pause.each do |duser|
        expect(page).to have_css('div', text: "Message envoyé à #{duser[:mail]}")
        expect(TUser.get(duser[:id])).to have_mail(subject: msg_sujet, after: start_time)
      end
      pitch("La confirmation a été donnée de l'envoi à chaque icarien et chaque icarien a bien reçu le message.")

    end





    scenario 'peut envoyer un message aux actifs seulement' do

      # Avant toute chose, on s'assure qu'il n'existe pas un mailing
      # enregistré
      File.delete(mailing_json_path) if File.exists?(mailing_json_path)

      phil.rejoint_le_site
      phil.click('contact', within: '#footer')
      pitch("Je m'identifie et envoie un mail aux actifs.")
      expect(page).to have_titre("Mailing-list")

      start_time = Time.now.to_i

      # *** Test ***
      msg_sujet = "Sujet du #{formate_date} aux actifs"
      msg_message  = "<p><%= pseudo %>,</p><p>C'est un message de mailing pour les actifs.</p>"

      expect(page).to have_css('input#envoi_titre')
      fill_in 'envoi_titre', with: msg_sujet
      expect(page).to have_css('textarea#envoi_message')
      fill_in 'envoi_message', with: msg_message
      expect(page).to have_css('input#cb-statut-pause')
      check('cb-statut-actif')
      expect(page).to have_css('select#message_format')
      select('Erb', from: 'message_format')
      click_button(UI_TEXTS[:btn_apercu])

      # *** Vérification ***

      expect(find('fieldset#mail-version-femme')).to have_content msg_sujet
      expect(find('fieldset#mail-version-homme')).to have_content msg_sujet
      # Le fichier mailing.json existe
      expect(File.exists?(mailing_json_path)).to eq(true)

      # On récupère les icariens actif
      users_actifs = db_exec("SELECT id, pseudo, mail FROM users WHERE SUBSTRING(options,1,1) = '0' AND SUBSTRING(options,4,1) = '0' AND SUBSTRING(options,17,1) = '2'")
      # On m'ajoute car je suis aussi toujours concerné
      users_actifs << {id:phil.id, pseudo:phil.pseudo, mail:phil.mail}
      # On récupère les inactifs pour s'assurer qu'ils ne reçoivent pas le
      # message
      users_inactifs = db_exec("SELECT id, pseudo, mail FROM users WHERE SUBSTRING(options,1,1) = '0' AND SUBSTRING(options,4,1) = '0' AND SUBSTRING(options,17,1) = '4'")

      within('fieldset#liste-destinataires') do
        users_actifs.each do |udata|
          expect(page).to have_content(udata[:pseudo])
        end
        users_inactifs.each do |udata|
          expect(page).not_to have_content(udata[:pseudo])
        end
      end

      # *** On procède à l'envoi ***
      expect(page).to have_link(UI_TEXTS[:proceed_envoi])
      click_link(UI_TEXTS[:proceed_envoi])

      # *** Vérifications ***

      # sleep 60
      users_actifs.each do |duser|
        # next if duser[:id] == phil.id
        expect(page).to have_css('div', text: "Message envoyé à #{duser[:mail]}")
        expect(TUser.get(duser[:id])).to have_mail(subject: msg_sujet, after: start_time)
      end
      users_inactifs.each do |duser|
        expect(page).not_to have_css('div', text: "Message envoyé à #{duser[:mail]}")
        expect(TUser.get(duser[:id])).not_to have_mail(subject: msg_sujet, after: start_time)
      end
      pitch("La confirmation a été donnée de l'envoi à chaque actif et chaque actif a bien reçu le message. Aucun icarien inactif n'a été contacté.")

    end










    scenario 'peut envoyer un mailing-list enregistré avant' do
      implementer(__FILE__, __LINE__)
    end


    scenario 'ne peut pas transmettre deux fois un même mailing-list (en rechargeant la page)' do
      implementer(__FILE__, __LINE__)
    end



    scenario 'peut procéder à la destruction d’un mailing enregistré' do
      implementer(__FILE__, __LINE__)
    end
  end # / fin context administrateur
end
