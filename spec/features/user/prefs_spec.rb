# encoding: UTF-8
=begin
  Test des préférences
=end
feature "Préférences" do
  before(:all) do
    degel('validation_inscription')
    # Les messages et erreur de la section préférences
    require './_lib/pages/bureau/preferences/constants_public'
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

  scenario 'Les options doivent bien se régler dans la page des préférences', only:true do
    degel('demarrage_module')
    extend SpecModuleMarion
    extend SpecModuleNavigation
    marion.login
    goto('bureau/preferences')
    save_screenshot('marion-preferences-init.png')

    # Les options actuelles
    options = marion.options
    after_login     = marion.option(18)
    freqs_actua     = marion.option(4)
    contact_admin   = marion.option(26)
    contact_icarien = marion.option(27)
    contact_wold    = marion.option(28)


    # Vérifications préliminaire
    # --------------------------
    # Les menus doivent être bien réglés
    within('form#preferences-form') do
      expect(page).to have_select('prefs-after_login', selected: Route::REDIRECTIONS[after_login][:hname])
    end

    # Procéder au test
    # ----------------
    # On change les valeurs des préférences et on les enregistre


    # Pour vérifier, on se déconnecte, on se reconnecte et
    # on revient sur les préférences
    marion.deconnect
    marion.login
    goto('bureau/preferences')
    save_screenshot('marion-preferences-init.png')
    # Les menus doivent être bien réglés
    within('form#preferences-form') do
      expect(page).to have_select('prefs-after_login',
        selected: Route::REDIRECTIONS[after_login][:hname]),
        "La redirection après identification est mauvaise"
    end

  end
end
