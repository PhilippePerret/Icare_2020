# encoding: UTF-8
=begin
  Test de la destruction d'un user
=end


feature "Destruction d'un icarien" do

  scenario "Un non icarien ne peut pas rejoindre son profil" do
    goto("user/destroy")
    expect(page).not_to have_content("Destruction"),
      "Un non icarien ne devrait pas pouvoir rejoindre son bureau"
    expect(page).to have_selector('h2', text: 'Identification'),
      "Un non icarien devrait être conduit au formulaire d'identification"
  end

  scenario 'Une icarienne peut détruire son profil', only:true do
    extend SpecModuleMarion
    degel('envoi_travail')
    identify_marion
    goto("user/profil")
    expect(page).to have_button('Détruire le profil')
    click_on 'Détruire le profil'
    expect(page).to have_selector('h2', text:'Destruction du profil')
    # TODO CONTINUER DE TESTER JUSQU'À LA FIN
  end
end
