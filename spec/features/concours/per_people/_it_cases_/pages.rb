# encoding: UTF-8
# frozen_string_literal: true
=begin
  IT-CASES pour les pages (qu'on peut atteindre ou pas)
=end

# Teste si le visiteur (quelconque, concurrent, juré ou non) atteint bien
# la simple annonce du concours, en phase 0, qui permet aussi de s'inscrire.
def peut_atteindre_lannonce_du_prochain_concours
  scenario "peut atteindre l'annonce du prochain concours" do
    try_identify_visitor
    goto("concours")
    expect(page).to be_page_annonce_concours
  end
end

def atteint_la_page_daccueil_du_concours(phase)
  it "peut atteindre la page d'accueil du concours" do
    try_identify_visitor
    goto("concours")
    expect(page).to be_accueil_concours(phase)
  end
end #/ atteint_la_page_daccueil_du_concours

# Utiliser it { ne_peut_pas_atteindre_la_section_evalutation } pour tester
# que le membre courant ne peut pas atteindre la section d'évaluation
def ne_peut_pas_atteindre_la_section_evalutation
  it "ne peut pas atteindre la section d'évaluation" do
    try_identify_visitor
    goto("concours/evaluation")
    expect(page).not_to be_page_evaluation
    expect(page).to be_identification_evaluator
  end
end

def peut_rejoindre_son_espace_personnel
  it "peut rejoindre son espace personnel" do
    try_identify_visitor
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
  end
end

def ne_peut_pas_atteindre_lespace_personnel
  it "ne peut pas atteindre l'espace personnel du concours" do
    try_identify_visitor
    goto("concours/espace_concurrent")
    expect(page).not_to be_espace_personnel
    expect(page).to be_identification_concours
  end
end

def ne_peut_pas_atteindre_le_palmares
  it "ne peut pas atteindre le palmarès du conccours" do
    try_identify_visitor
    goto("concours/palmares")
    expect(page).not_to be_palmares_concours(TConcours.current.phase)
    expect(page).to be_identification_concours
  end
end

def peut_rejoindre_la_page_des_palmares
  it "peut atteindre le palmarès du concours de l'année" do
    try_identify_visitor
    goto("concours/palmares")
    expect(page).to be_palmares_concours(TConcours.current.phase)
  end
end #/ peut_rejoindre_la_page_des_palmares
