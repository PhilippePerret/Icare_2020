# encoding: UTF-8
=begin
  Test des préférences
=end
feature "Préférences" do
  before(:all) do
    degel('validation_inscription')
    # Les messages et erreur de la section préférences
    require "#{FOLD_REL_PAGES}/bureau/preferences/constants_public"
    # Les valeurs des routes after-login
    require './_lib/required/__first/constants/routes'
    # => Route::REDIRECTIONS
  end

  def goto_preferences_as_marion
    extend SpecModuleMarion
    identify_marion
    goto "bureau/preferences"
  end #/ goto_preferences_as_marion

  scenario "un visiteur quelconque ne peut pas atteindre les préférencs" do
    extend SpecModuleNavigation
    goto "bureau/preferences"
    expect(page).not_to have_css('h2', text: 'Préférences')
    expect(page).to have_css('h2', text: 'Identification')
  end

  scenario 'un visiteur identifié peut atteindre ses préférences' do
    goto_preferences_as_marion
    save_screenshot('icarien-can-reach-preferences.png')
    expect(page).to have_css('h2', text: 'Vos préférences')
  end

  scenario 'une icarienne inactive ne trouve pas le champ titre projet' do
    degel('validation_inscription')
    goto_preferences_as_marion
    expect(page).not_to have_css('input[type="text"][name="prefs-project_name"]'),
      "La page NE devrait PAS afficher un champ pour indiquer le titre de son projet (icarien inactif)"
  end

  scenario 'une icarienne en activité peut modifier le titre de son projet courant' do
    degel('demarrage_module')
    goto_preferences_as_marion
    # Vérification préliminaire
    expect(marion.project_name).to eq(nil),
      "Marion ne devrait pas encore avoir de titre de projet"
    expect(page).to have_css('input[type="text"][name="prefs-project_name"]'),
      "La page devrait afficher un champ pour indiquer le titre de son projet"

    new_titre = "Mon projet #{Time.now.to_i}".freeze
    within('form#preferences-form') do
      fill_in('prefs-project_name', with: new_titre)
      click_button('Enregistrer')
    end
    save_screenshot('marion-change-preferences.png')
    expect(page).to have_content(MESSAGES[:confirm_titre_projet_saved]),
      "La page devrait afficher le message de confirmation du changement de titre".freeze
  end

  scenario 'Les options doivent bien se régler dans la page des préférences' do
    degel('demarrage_module')
    extend SpecModuleMarion
    extend SpecModuleNavigation
    marion.login
    goto('bureau/preferences')
    save_screenshot('marion-preferences-init.png')

    # Les options actuelles
    options = marion.options
    after_login     = marion.option(18)
    freqs_actus     = marion.option(4)
    contact_admin   = marion.option(26)
    contact_icarien = marion.option(27)
    contact_world   = marion.option(28)
    share_histo     = marion.option(21)

    # Vérifications préliminaire
    # --------------------------
    # Les menus doivent être bien réglés
    within('form#preferences-form') do
      expect(page).to have_select('prefs-after_login',      selected: Route::REDIRECTIONS[after_login][:hname])
      expect(page).to have_select('prefs-freqs_actus',      selected: DATA_FREQ_MAIL[freqs_actus][:name])
      expect(page).to have_select('prefs-contact_admin',    selected: DATA_CONTACTS[contact_admin][:name])
      expect(page).to have_select('prefs-contact_icarien',  selected: DATA_CONTACTS[contact_icarien][:name])
      expect(page).to have_select('prefs-contact_world',    selected: DATA_CONTACTS[contact_world][:name])
      expect(page).to have_select('prefs-share_histo',      selected: DATA_SHARINGS[share_histo][:name])
    end

    # Procéder au test
    # ----------------
    # On change les valeurs des préférences et on les enregistre
    # Pour les trouver, on prend les clés et on en choisit des
    # différentes
    def other_value_in(liste, cur_value)
      new_value = cur_value
      vals = liste.keys
      nums = vals.count
      while new_value == cur_value
        new_value = vals[rand(nums)]
      end
      return new_value
    end #/ other_value_in

    new_after_login     = other_value_in(Route::REDIRECTIONS, after_login)
    new_freqs_actus     = other_value_in(DATA_FREQ_MAIL, freqs_actus)
    new_contact_admin   = other_value_in(DATA_CONTACTS, contact_admin)
    new_contact_icarien = other_value_in(DATA_CONTACTS, contact_icarien)
    new_contact_world   = other_value_in(DATA_CONTACTS, contact_world)
    new_share_histo     = other_value_in(DATA_SHARINGS, share_histo)

    within('form#preferences-form') do
      select(Route::REDIRECTIONS[new_after_login][:hname], from:'prefs-after_login')
      select(DATA_FREQ_MAIL[new_freqs_actus][:name], from:'prefs-freqs_actus')
      select(DATA_CONTACTS[new_contact_admin][:name], from: 'prefs-contact_admin')
      select(DATA_CONTACTS[new_contact_icarien][:name], from: 'prefs-contact_icarien')
      select(DATA_CONTACTS[new_contact_world][:name], from: 'prefs-contact_world')
      select(DATA_SHARINGS[new_share_histo][:name], from: 'prefs-share_histo')
      click_on 'Enregistrer'
    end

    # Pour vérifier, on se déconnecte, on se reconnecte et
    # on revient sur les préférences
    marion.deconnect
    marion.login
    goto('bureau/preferences')
    save_screenshot('marion-preferences-init.png')
    # Les menus doivent être bien réglés
    within('form#preferences-form') do
      expect(page).not_to have_select('prefs-after_login',
        selected: Route::REDIRECTIONS[after_login][:hname]),
        "La redirection après identification ne devrait plus être #{Route::REDIRECTIONS[after_login][:hname]}"
      expect(page).to have_select('prefs-after_login',
        selected: Route::REDIRECTIONS[new_after_login][:hname]),
        "La redirection après identification devrait être #{Route::REDIRECTIONS[new_after_login][:hname]}"

      expect(page).not_to have_select('prefs-freqs_actus',
        selected: DATA_FREQ_MAIL[freqs_actus][:name]),
        "La fréquence des actualités ne devrait plus être #{DATA_FREQ_MAIL[freqs_actus][:name]}"
      expect(page).to have_select('prefs-freqs_actus',
        selected: DATA_FREQ_MAIL[new_freqs_actus][:name]),
        "La fréquence des actualités devrait être #{DATA_FREQ_MAIL[new_freqs_actus][:name]}"

      expect(page).not_to have_select('prefs-contact_admin',
        selected: DATA_CONTACTS[contact_admin][:name]),
        "Le contact avec l'administration ne devrait plus être #{DATA_CONTACTS[contact_admin][:name]}"
      expect(page).to have_select('prefs-contact_admin',
        selected: DATA_CONTACTS[new_contact_admin][:name]),
        "Le contact avec l'administration devrait être #{DATA_CONTACTS[new_contact_admin][:name]}"

      expect(page).not_to have_select('prefs-contact_icarien',
        selected: DATA_CONTACTS[contact_icarien][:name]),
        "Le contact avec les icariens ne devrait plus être #{DATA_CONTACTS[contact_icarien][:name]}"
      expect(page).to have_select('prefs-contact_icarien',
        selected: DATA_CONTACTS[new_contact_icarien][:name]),
        "Le contact avec les icariens devrait être #{DATA_CONTACTS[new_contact_icarien][:name]}"

      expect(page).not_to have_select('prefs-contact_world',
        selected: DATA_CONTACTS[contact_world][:name]),
        "Le contact avec le reste du monde ne devrait plus être #{DATA_CONTACTS[contact_world][:name]}"
      expect(page).to have_select('prefs-contact_world',
        selected: DATA_CONTACTS[new_contact_world][:name]),
        "Le contact avec le reste du monde devrait être #{DATA_CONTACTS[new_contact_world][:name]}"

      expect(page).not_to have_select('prefs-share_histo',
        selected: DATA_SHARINGS[share_histo][:name]),
        "Le partage de l'historique ne devrait plus être #{DATA_SHARINGS[share_histo][:name]}"
      expect(page).to have_select('prefs-share_histo',
        selected: DATA_SHARINGS[new_share_histo][:name]),
        "Le partage de l'historique devrait être #{DATA_SHARINGS[new_share_histo][:name]}"

    end #/within le formulaire

  end
end
