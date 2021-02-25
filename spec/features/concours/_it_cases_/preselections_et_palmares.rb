# encoding: UTF-8
# frozen_string_literal: true

def peut_rejoindre_la_page_des_palmares
  it 'peut rejoindre la page des palmarès' do
    goto('concours/palmares')
    expect(page).to be_palmares_concours
  end
end #/ peut_rejoindre_la_page_des_palmares

def ne_peut_pas_voir_la_liste_des_preselectionnes(raison = "Les présélections sont en cours")
  it 'ne peut pas voir la liste des présélectionnés' do
    goto('concours/palmares')
    expect(page).to be_palmares_concours
    expect(page).to have_content(raison)
  end
end #/ ne_peut_pas_voir_la_liste_des_preselectionnes

def peut_voir_la_liste_des_preselectionnes
  it "peut voir la liste des préselectionnés" do
    goto("concours/palmares")
    expect(page).to be_palmares_concours
  end
end #/ peut_voir_la_liste_des_preselectionnes

def ne_peut_pas_voir_le_palmares_final(raison = "trop tôt pour voir le palmarès final")
  it 'ne peut pas voir le palmarès final' do
    goto("concours/palmares")
    expect(page).to be_palmares_concours
    expect(page).to have_content(raison)
  end
end #/ ne_peut_pas_voir_le_palmares_final

def peut_voir_les_palmares_precedents
  it 'peut voir les palmarès précédents grâce à un lien sur la page des palmarès' do
    goto("concours/palmares")
    expect(page).to be_palmares_concours
    an = TConcours.get_another_year.freeze
    expect(page).to have_link("Palmarès de l’année #{an}")
    click_on("Palmarès de l’année #{an}")
    expect(page).to have_titre("Palmarès de l'année #{an}")
    expect(page).to have_link("Palmarès de l’année courante")
    click_on("Palmarès de l’année courante")
    expect(page).to be_palmares_concours
  end
  it 'peut rejoindre un palmares précédent par url' do
    an = TConcours.get_another_year.freeze
    goto("concours/palmares?an=#{an}")
    expect(page).to have_titre("Palmarès de l'année #{an}")
    expect(page).to have_link("Palmarès de l’année courante")
    click_on("Palmarès de l’année courante")
    expect(page).to be_palmares_concours
  end
end #/ peut_voir_les_palmares_precedents
