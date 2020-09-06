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
      pending "à implémenter"
      pitch("Un icarien ayant oublié son mot de passe peut en demander un nouveau et le changer.")
      goto("user/login")
      expect(page).to have_css('a', text: "Mot de passe oublié")
      click_link("Mot de passe oublié")
      expect(page).to have_titre("Mot de passe oublié")
      expect(page).to have_css('form#form-password-forgotten')
      within('form#form-password-forgotten') do
        fill_in('user_mail', with: marion.mail)
        click_on(UI_TEXTS[:btn_send_mail])
      end
    end
  end
end
