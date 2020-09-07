# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test du mot de passe oublié
=end
feature "Mot de passe oublié" do
  before(:all) do
    require './_lib/pages/user/forgot_password/constants'
    degel('define_sharing')
  end
  context 'un faux icarien' do
    scenario "ne peut pas recouvrer son mot de passe" do
      pending "à implémenter"
    end
  end

  context 'Un vrai icarien' do
    scenario 'peut recouvrer un mot de passe avec son adresse mail' do

      # On prend l'ancien mot de passe pour le comparer au nouveau
      old_cpassword = marion.cpassword

      start_time = Time.now.to_i

      pitch("Marion, qui a oublié son mot de passe, peut en demander un nouveau et le changer.")
      goto("user/login")
      expect(page).to have_css('a', text: "Mot de passe oublié")
      click_link("Mot de passe oublié")
      expect(page).to have_titre(UI_TEXTS[:titre_password_forgotten])
      expect(page).to have_css('form#form-password-forgotten')

      # On s'assure que marion n'ait pas encore reçu de mail
      expect(marion).not_to have_mail(after: start_time, subject:MESSAGES[:sujet_mail_envoi_password])

      # Marion donne son mail et soumet le formulaire
      within('#form-password-forgotten') do
        fill_in('user_mail', with: marion.mail)
        click_on(UI_TEXTS[:btn_send_mail])
      end
      pitch("Marion reçoit un mail contenant un nouveau mot de passe provisoire")
      marion.reset
      expect(marion.cpassword).not_to eq(old_cpassword)
      expect(marion).to have_mail(after: start_time, subject:MESSAGES[:sujet_mail_envoi_password])

      # On récupère le mot de passe dans le mail
      lemail = TMails.for(marion.mail, {after: start_time, subject:MESSAGES[:sujet_mail_envoi_password]}).first
      new_pwd = lemail.content.match(/<\!\-\- NPWD \-\->(.*?)<\!\-\- \/NPWD \-\->/).to_a[1]

      pitch("Marion peut se connecter avec son nouveau mot de passe")
      goto("user/login")
      within("form#user-login") do
        fill_in("user_mail", with: marion.mail)
        fill_in("user_password", with: new_pwd)
        click_on("S’identifier")
      end

      # Si on a bien le message d'accueil, c'est que la procédure fonctionne
      # parfaitement.
      expect(page).to have_message("Soyez la bienvenue, Marion")

    end
  end
end
