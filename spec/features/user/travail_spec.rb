# encoding: UTF-8
feature "Travail d'un icarien" do
  scenario "Un icarien en activité trouve son travail sur son bureau" do
    degel('demarrage_module')
    pitch('Après avoir démarré son module, Marion rejoint son travail courant…'.freeze)
    marion.rejoint_son_bureau
    click_on('Travail courant')
    screenshot('marion-dans-sa-section-travail')
    expect(page).to have_titre('Votre travail', {retour:{route:'bureau/home', text:'Bureau'}})
    pitch('… et trouve un bon titre'.freeze)

    expect(page).to have_css('h1', text: "1. Introduction à l'analyse de film")
    pitch('… le titre de l’étape courante')

    [
      'div#etat-des-lieux',
      'section.etape_work',
      'fieldset#etape-work',
      'fieldset#etape-minifaq',
      'fieldset#quai-des-docs'
    ].each do |selector|
      expect(page).to have_selector(selector)
    end
    pitch('… les bonnes sections (et fieldset)')

    [
      'Travail à effectuer',
      'OBJECTIF',
      'ÉNONCÉ DU TRAVAIL',
      'ÉLÉMENTS DE MÉTHODES',
      'LIENS UTILES',
      'Quai des docs'
    ].each do |legende|
      expect(page).to have_css('fieldset legend', text: legende)
    end
    pitch('… les bonnes légendes')

    expect(page).to have_css('a[href="bureau/sender?rid=send_work_form"]', text:'Remettre le travail'),
      "La page devrait contenir le bouton pour remettre le travail"
    pitch("… un bouton pour remettre son travail")

  end
end
