# encoding: UTF-8
=begin
  Test de la destruction d'un user
=end
require_relative './_required'
include SpecModuleMarion

feature "Destruction du profil" do
  # Noter qu'il s'agit d'une destruction complète, avec même suppression
  # de la donnée dans la table users. Il ne s'agit pas d'une mise du bit
  # 3 à 1 et du bit 16 à 5
  before :all do
    require './_lib/_pages_/user/profil/constants'
    require './_lib/_pages_/user/destroy/constants'
  end

  scenario "Un non icarien ne peut pas rejoindre son profil" do
    goto("user/destroy")
    expect(page).not_to have_content("Destruction"),
      "Un non icarien ne devrait pas pouvoir rejoindre son bureau"
    expect(page).to have_selector('h2', text: 'Identification'),
      "Un non icarien devrait être conduit au formulaire d'identification"
  end

  scenario 'Une icarienne peut détruire complètement son profil' do
    # extend SpecModuleMarion
    degel('envoi_travail')
    identify_marion
    goto("user/profil")
    expect(page).to have_link(UI_TEXTS[:btn_detruire_profil])
    click_on UI_TEXTS[:btn_detruire_profil]
    expect(page).to have_selector('h2', text:'Destruction du profil')
    expect(page).to have_css('form#destroy-user-form')
    within("form#destroy-user-form") do
      fill_in('user_password', with: marion.password)
      click_on(UI_TEXTS[:btn_detruire_definitivement_profil])
    end
    expect(page).to have_message(MESSAGES[:destroy_confirm] % {pseudo: marion.pseudo})

    res = db_get('users', marion.id)
    expect(res).to eq(nil)
    # Tous ses messages frigo ont été anonymisés
    {
      'frigo_discussions' => "de discussions frigo avec Marion",
      'frigo_messages'    => "de messages frigo de Marion",
      'actualites'        => "d'actualités de Marion",
      'minifaq'           => "de questions minifaq de Marion",
      'temoignages'       => "de témoignages de Marion",
      'lectures_qdd'      => "de lecture QDD de Marion"
    }.each do |dbtable, err_msg|
      res = db_exec("SELECT * FROM #{dbtable} WHERE user_id = ?", [marion.id])
      expect(res).to be_empty,
        "Il ne devrait plus y avoir de #{err_msg}"
    end

  end

  context 'Une icarienne qui a participé à une session de concours' do
    before :all do
      headless false
      degel("marion-concurrente-concours")
    end
    scenario 'perd également toutes les informations sur le concours' do
      require_support('concours')
      marion_concurrent_id = marion.concurrent_id.freeze
      folder_concours_marion = marion.folder_concours.freeze
      if not File.exists?(folder_concours_marion)
        # Juste pour l'avoir et voir s'il sera détruit
        FileUtils.mkdir_p(folder_concours_marion)
      end

      # *** vérifications prélimintaires ***
      expect(marion).to be_concurrent
      expect(marion_concurrent_id).not_to eq(nil)
      expect(File).to be_exists(folder_concours_marion)

      # Marion procède à sa destruction
      identify_marion
      goto("user/profil")
      expect(page).to have_link(UI_TEXTS[:btn_detruire_profil])
      click_on UI_TEXTS[:btn_detruire_profil]
      expect(page).to have_selector('h2', text:'Destruction du profil')
      within("form#destroy-user-form") do
        fill_in('user_password', with: marion.password)
        click_on(UI_TEXTS[:btn_detruire_definitivement_profil])
      end
      expect(page).to have_message(MESSAGES[:destroy_confirm] % {pseudo: marion.pseudo})

      # *** Vérification ***
      # Note : ici, Marion n'existe plus, donc il ne faut plus utiliser marion,
      # seulement pour des valeurs comme son mail, etc. si on ne reset pas
      # son instance
      res = db_exec("SELECT * FROM concours_concurrents WHERE mail = ?", [marion.mail]).first
      expect(res).to eq(nil),
        "Marion ne devrait plus avoir d'enregistrement comme concurrente du concours…"
      res = db_exec("SELECT * FROM concurrents_per_concours WHERE concurrent_id = ?", marion_concurrent_id)
      expect(res).to be_empty,
        "Marion ne devrait plus avoir aucun participation aux concours"
      expect(File).not_to be_exist(folder_concours_marion),
        "Marion ne devrait plus avoir de dossier concours"
    end
  end
end
