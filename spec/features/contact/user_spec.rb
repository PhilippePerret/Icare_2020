# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test d'envoi de mail par un user
=end
require_relative './_required'

feature "Par le formulaire de contact" do
  before(:all) do
    degel('real-icare')
  end

  context 'un visiteur quelconque' do
    scenario 'peut rejoindre le formulaire de contact' do
      goto("")
      within('#footer'){click_on('contact')}
      expect(page).to be_contact_page
    end
    scenario 'peut envoyer un message avec titre et message' do
      start_time = Time.now.to_i
      goto("contact/mail")
      expect(page).to be_contact_page
      # *** Test ***
      # ON remplit le formulaire et on le soumet
      msg_sujet = "Sujet pour Phil par invité du #{formate_date}"
      msg_message  = "Un message pour Phil envoyé depuis le formulaire de contact par un invité, le #{formate_date}."
      within('form#contact-form') do
        fill_in 'envoi_titre',    with: msg_sujet
        fill_in 'envoi_message',  with: msg_message
        click_on 'Envoyer'
      end
      # *** Vérification ***
      expect(page).to have_message(MESSAGES[:contact][:confirme_envoi])
      expect(phil).to have_mail(after: start_time, subject: msg_sujet, message: msg_message)
    end
  end # un visiteur quelconque

  context 'un icarien identifié' do

    let(:unicarien) { @unicarien ||= TUser.get_random(real:true)}

    scenario 'peut rejoindre le formulaire de contact' do
      # unicarien = TUser.get_random(real:true)
      # puts "unicarien = #{unicarien.inspect}"
      unicarien.rejoint_le_site
      unicarien.click('contact', within:'#footer')
      expect(page).to be_contact_page(icarien: true)
    end

    scenario 'peut m’envoyer un message' do
      start_time = Time.now.to_i
      # unicarien = TUser.get_random(real:true)
      unicarien.rejoint_le_site
      unicarien.click('contact', within:'#footer')
      expect(page).to be_contact_page(icarien: true)

      # *** Test ***
      # ON remplit le formulaire et on le soumet
      msg_sujet = "Sujet pour Phil du #{formate_date} aux actifs"
      msg_message  = "Un message pour Phil envoyé depuis le formulaire de contact, le #{formate_date}."
      within('form#contact-form') do
        fill_in 'envoi_titre', with: msg_sujet
        fill_in 'envoi_message', with: msg_message
        click_on('Envoyer')
      end

      # *** Vérification ***
      expect(page).to have_message(MESSAGES[:contact][:confirme_envoi])
      expect(phil).to have_mail(after: start_time, subject: msg_sujet, message: msg_message)

    end
  end

end
