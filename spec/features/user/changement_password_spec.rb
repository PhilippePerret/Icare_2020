# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode pour tester le changement de mot de passe
=end
require_relative './_required'

feature "Changement du mot de passe" do
  before(:all) do
    degel('define_sharing')
  end

  context 'un visiteur quelconque' do
    scenario 'ne peut pas changer son mot de passe' do
      pitch("Un visiteur quelconque essaie de rejoindre la page de changement de mot de passe. Il est renvoyé à l'identification.")
      goto('user/change_password')
      expect(page).not_to have_titre('Changement du mot de passe')
      expect(page).to have_titre('Identification')
    end
  end






  context 'un icarien' do

    scenario 'peut rejoindre le changement de mot de passe par son profil' do
      pitch("Marion, en s'identifiant, peut rejoindre le changement de mot de passe par son profil.".freeze)
      marion.rejoint_le_site
      find('section#header').click
      click_on('Bureau')
      click_on('Profil')
      click_on(UI_TEXTS[:btn_lien_change_password])
      expect(page).to have_titre('Changement du mot de passe')
    end


    scenario 'peut changer son mot de passe' do
      old_password = 'motdepasse'
      new_password = 'monnouveaumotdepasse'

      marion.rejoint_le_site
      goto('user/change_password')
      expect(page).to have_titre('Changement du mot de passe')
      within('form#form-change-password') do
        fill_in('old_password', with: old_password)
        fill_in('new_password', with: new_password)
        click_on(UI_TEXTS[:btn_change_password])
      end
      expect(page).to have_content(MESSAGES[:new_password_saved])
      logout

      pitch("En revenant sur le site, Marion ne peut pas s'identifier avec son vieux mot de passe.")
      goto('user/login')
      login_in_form(mail:marion.mail, password:old_password)
      expect(page).to have_titre('Identification')
      expect(page).to have_erreur('Je ne vous reconnais pas')

      pitch("Mais elle peut le faire avec le nouveau.")
      login_in_form(mail:marion.mail, password:new_password)
      expect(page).not_to have_titre('Identification')
      expect(page).not_to have_erreur('Je ne vous reconnais pas')
      expect(page).to have_content('Soyez la bienvenue')
      logout

      degel('define_sharing')

    end











    scenario 'peut changer son mot de passe avec toutes les erreurs possibles' do
      pitch("Marion, pour changer son mot de passe, va faire toutes les erreurs possibles et imaginables, sans y parvenir, jusqu'à finalement utiliser un bon mot de passe.".freeze)

      def compose_message_error(key_error)
        ERRORS[:newpass_invalide] % ERRORS[key_error].downcase
      end #/ compose_message_error

      old_password = 'motdepasse' # le mot de passe actuel de Marion

      marion.rejoint_le_site
      screenshot('marion-to-change-password-with-errors')
      goto('user/change_password')
      expect(page).to have_titre('Changement du mot de passe')

      [
        ['',                  :newpass_required],
        ['court',             compose_message_error(:password_too_short)],
        ['c',                 compose_message_error(:password_too_short)],
        ['c'*51,              compose_message_error(:password_too_long)],
        ['mauvais nouveau',   compose_message_error(:password_invalid)],
        ['^m^a^u^v^a^i^s',    compose_message_error(:password_invalid)],
        ['unbon45!sans?',     :the_last] # la bonne
      ].each do |new_password, error|

        within('form#form-change-password') do
          fill_in('old_password', with: old_password)
          fill_in('new_password', with: new_password)
          click_on(UI_TEXTS[:btn_change_password])
        end

        unless error == :the_last
          error = ERRORS[error] if error.is_a?(Symbol)
          expect(page).to have_error(error)
          expect(page).not_to have_content(MESSAGES[:new_password_saved])
        else
          expect(page).to have_content(MESSAGES[:new_password_saved])
        end

      end #/fin boucle sur tous les mauvais mot de passe

    end #/test de toutes les erreurs possibles

  end # context icarien
end
