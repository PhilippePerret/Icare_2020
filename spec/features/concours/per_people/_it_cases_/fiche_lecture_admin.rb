# encoding: UTF-8
# frozen_string_literal: true
=begin
  IT-CASES concernant l'administration du concours
=end
def ne_peut_pas_produire_les_fiches_de_lecture(as = :visitor)
  # Méthode qui s'assure que le visiteur courant, quel qu'il soit à part administrateur, ne peut pas lancer la production des fiches de lecture. Soit en rejoignant la section de production, soit par lien direct.
  require './_lib/_pages_/concours/xrequired/constants_mini'
  it "ne peut pas produire les fiches de lecture en se rendant dans la section administration" do
    goto("concours/admin?section=fiches_lecture")
    if as == :admin
      expect(page).to be_production_fiches_lecture(phase = TConcours.current.phase)
    else
      expect(page).not_to be_production_fiches_lecture
    end
  end
  it "ne peut pas produire les fiches de lecture par lien direct" do
    FileUtils.rm_rf(TEMP_CONCOURS_FOLDER)
    goto("concours/admin?section=fiches_lecture&op=produce_fiches_lecture")
    if as == :admin
      expect(page).to be_production_fiches_lecture
      expect(page).to have_erreur("Il est trop tôt pour produire les fiches de lecture…")
    else
      expect(page).not_to be_production_fiches_lecture
    end
    expect(Dir["#{TEMP_CONCOURS_FOLDER}/**/*.pdf"]).to be_empty
  end
end #/ ne_peut_pas_produire_les_fiches_de_lecture

def peut_produire_les_fiches_de_lecture
  # Méthode qui teste complètement la génération des fiches de lecture après l'évaluation complète des synopsis. C'est seulement une méthode d'administration.
  it "peut rejoindre la section contenant le bouton pour produire les fiches" do
    goto("concours/admin")
    expect(page).to be_dashboard_administration
    find('div.usefull-links .handler').hover
    expect(page).to have_link("Fiches de lecture"), "La page devrait contenir un menu pour rejoindre la section « Fiches de lecture »…"
    click_on('Fiches de lecture')
    expect(page).to be_production_fiches_lecture
  end

  it "peut lancer la procédure de production des fiches" do
    goto("concours/admin")
    expect(page).to be_dashboard_administration
    find('div.usefull-links .handler').hover
    click_on('Fiches de lecture')
    expect(page).to be_production_fiches_lecture
    click_on('Produire les fiches de lecture')
    expect(page).to be_production_fiches_lecture
  end

  it "produit des fiches cohérentes avec les évaluations" do
    # Note : c'est la plus grosse partie du test, on doit vraiment s'assurer
    # que les fiches de lecture sont produites en accord avec l'évaluation du
    # synopsis.
    goto("concours/admin")
    expect(page).to be_dashboard_administration
    find('div.usefull-links .handler').hover
    expect(page).to have_link("Fiches de lecture")
    click_on('Fiches de lecture')
  end
end #/ peut_produire_les_fiches_de_lecture
