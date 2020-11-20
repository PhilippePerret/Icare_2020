# encoding: UTF-8
=begin
  Test de la destruction d'un user
=end
require_relative './_required'

feature "Destruction d'un icarien" do
  before :all do
    require './_lib/_pages_/user/profil/constants'
  end

  scenario "Un non icarien ne peut pas rejoindre son profil" do
    goto("user/destroy")
    expect(page).not_to have_content("Destruction"),
      "Un non icarien ne devrait pas pouvoir rejoindre son bureau"
    expect(page).to have_selector('h2', text: 'Identification'),
      "Un non icarien devrait être conduit au formulaire d'identification"
  end

  scenario 'Une icarienne peut détruire son profil' do
    # extend SpecModuleMarion
    degel('envoi_travail')
    identify_marion
    goto("user/profil")
    expect(page).to have_link(UI_TEXTS[:btn_detruire_profil])
    click_on UI_TEXTS[:btn_detruire_profil]
    expect(page).to have_selector('h2', text:'Destruction du profil')
    # TODO CONTINUER DE TESTER JUSQU'À LA FIN
  end

  context 'Une icarienne qui a participé à une session de concours', only:true do
    before :all do
      degel("marion-concurrente-concours")
    end
    scenario 'perd également toutes les informations sur le concours' do
      require_support('concours')
      # *** vérifications prélimintaires ***
      expect(marion).to be_concurrent?

      # Marion procède à sa destruction
      identify_marion
      goto("user/profil")
      expect(page).to have_link(UI_TEXTS[:btn_detruire_profil])
      click_on UI_TEXTS[:btn_detruire_profil]
      expect(page).to have_selector('h2', text:'Destruction du profil')

      implementer(__FILE__,__LINE__)
    end
  end
end
