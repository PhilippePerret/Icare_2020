# encoding: UTF-8
# frozen_string_literal: true

def peut_evaluer_un_projet
  it "peut évaluer un projet" do
    goto('concours/evaluation')
    expect(page).to be_page_evaluation
    id_synopsis = first('div.synopsis')[:id].split('-')[1..2].join('-')
    id_concurrent = id_synopsis.split('-')[0]
    first('div.synopsis').click_on('Évaluer')
    expect(page).to have_titre("Évaluation de #{id_synopsis}")
    pending "à implémenter"
  end
end #/ peut_evaluer_un_projet

def ne_peut_plus_evaluer_les_projets
  it "ne peut plus evaluer les projets" do
    visit("concours/evaluation")
    expect(page).to be_page_evaluation
    id_synopsis = first('div.synopsis')[:id].split('-')[1..2].join('-')
    expect(first('div.synopsis')).not_to have_link('Évaluer')
  end
end #/ ne_peut_plus_evaluer_les_projets
