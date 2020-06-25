# encoding: UTF-8
=begin
  Test pour voir si, quand on tape une mauvaise route, on arrive sur la bonne page
=end
feature "Mauvaise route" do
  scenario "Utiliser une mauvaise route conduit à la bonne page" do
    goto("mauvais/bureau")
    screenshot('mauvais-route')
    expect(page).to have_selector('h2', text: 'Voie sans issue'),
      "Le titre de la page devrait être 'Voie sans issue'."
    expect(page).to have_content("mauvais/bureau"),
      "La page devrait afficher la mauvaise route."
    expect(page).to have_selector('img#voie-sans-issue[src="img/icones/voie-sans-issue.png"]'),
      "La page devrait contenir une image de voie sans issue"
    expect(page).to have_link("voir un plan", href:'plan'),
      "La page devrait contenir un lien vers le plan"
  end
end
