# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de la section concours
=end
feature "Accueil du concours de synopsis" do
  before(:all) do
    require_support('concours')
    degel('concours')
  end
  scenario "Un visiteur quelconque tombe sur une page valide" do
    pitch("Un visiteur quelconque trouve une page de concours valide.")
    goto("concours/accueil")
    expect(page).to have_titre(UI_TEXTS[:concours_titre_home_page])
    expect(page).to have_css("span.annee-concours", text: ANNEE_CONCOURS_COURANTE.to_s),
      "La page devrait indiquer l'année du concours"
    expect(page).to have_link(UI_TEXTS[:concours_bouton_inscription]),
      "La page devrait présenter un bouton pour s'inscrire"
    expect(page).to have_link(UI_TEXTS[:concours_btn_identifiez_vous]),
      "La page devrait présenter un bouton pour s'identifier quand on est inscrit"
    expect(page).to have_css("h3", text: "Objet du concours")
    expect(page).to have_css("h3", text: "Trois Prix")
    expect(page).to have_css("h3", text: "Thème")
    expect(page).to have_css("span.concours-theme", text: /#{TConcours.current.theme.upcase}/i),
      "La page devrait présenter le thème du concours : #{TConcours.current.theme.upcase}"
    expect(page).to have_css("h3", text: "Fichier de candidature")
    expect(page).to have_link("format du fichier de candidature", href: "concours/dossier"),
      "La page devrait présenter un lien pour voir le format du fichier de candidature"
    expect(page).to have_css("h3", text: "Règlement complet")
    expect(page).to have_link("Règlement du concours"),
      "La page devrait posséder un lien vers le règlement du concours"
    expect(page).to have_css("h3", text: "Faq")
    expect(page).to have_link("Foire Aux Questions", href:"concours/faq"),
      "La page devrait posséder un lien conforme vers la F.A.Q."
  end

  scenario 'tous les liens de la page d’accueil conduisent aux bons endroits' do
    def revenir_accueil
      click_on("Le Concours")
    end #/ revenir_accueil
    pitch("Un visiteur quelconque peut rejoindre tous les lieux autorisés")
    goto("concours/accueil")
    expect(page).to have_link(UI_TEXTS[:concours_bouton_inscription])
    click_on(UI_TEXTS[:concours_bouton_inscription])
    expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
    revenir_accueil
    expect(page).to have_link(UI_TEXTS[:concours_btn_identifiez_vous])
    click_on(UI_TEXTS[:concours_btn_identifiez_vous])
    expect(page).to have_titre("Identification au concours")
    revenir_accueil
    expect(page).to have_link("format du fichier de candidature", href: "concours/dossier")
    click_on("format du fichier de candidature")
    expect(page).to have_titre("Fichier du concours")
    revenir_accueil
    expect(page).to have_link("Foire Aux Questions", href:"concours/faq")
    # first(text:"Foire Aux Questions").click
    click_on(class:'btn-faq')
    expect(page).to have_titre("FAQ du concours")
    revenir_accueil
    expect(page).to have_link("Règlement du concours")
    click_on("Règlement du concours")
    sleep 10


  end
end
