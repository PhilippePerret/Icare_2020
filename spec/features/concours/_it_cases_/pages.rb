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
    expect(page).to be_accueil_concours(0)
  end
end

def atteint_la_page_daccueil_du_concours(phase)
  it "peut atteindre la page d'accueil du concours" do
    try_identify_visitor
    goto("concours")
    expect(page).to be_accueil_concours(phase)
  end
end #/ atteint_la_page_daccueil_du_concours

def peut_rejoindre_toutes_les_sections_depuis_laccueil
  def revenir_accueil; click_on("Le Concours") end
  it "peut rejoindre toutes les sections depuis l’accueil" do
    visitor&.logout
    goto("concours/accueil")
    phase_min = TConcours.current.phase < 2
    UI_TEXTS[:concours_bouton_inscription]  = phase_min ? "vous inscrire" : "Inscription au concours"
    UI_TEXTS[:concours_btn_identifiez_vous] = phase_min ? "vous identifier" : "Identifiez-vous"
    expect(page).to have_link(UI_TEXTS[:concours_bouton_inscription])
    click_on(UI_TEXTS[:concours_bouton_inscription])
    expect(page).to have_titre(UI_TEXTS[:concours][:titres][:signup_page])
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
end #/ peut_rejoindre_toutes_les_sections_depuis_laccueil

# Utiliser it { ne_peut_pas_atteindre_la_section_evalutation } pour tester
# que le membre courant ne peut pas atteindre la section d'évaluation
def ne_peut_pas_atteindre_la_section_evalutation
  it "ne peut pas atteindre la section d'évaluation" do
    headless(false)
    goto("concours/evaluation")
    # Si le visiteur est identifié, il trouve le message :
    # "Un membre du jury ou un administrateur est requis"
    # Sinon, il trouve le formulaire d'identification
    if page.has_content?("Un membre du jury ou un administrateur est requis")
      expect(page).to have_content("Un membre du jury ou un administrateur est requis")
    else
      expect(page).not_to be_page_evaluation
      expect(page).to be_indentification_jury
    end
  end
end

def peut_rejoindre_son_espace_personnel(phase)
  it "peut rejoindre son espace personnel" do
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expected_textes = case phase
    when 0
      ["En attendant le démarrage"]
    when 1
      ['informations sur le concours actuel']
    when 2
      ['informations sur le concours actuel', 'Présélections']
    else
      []
    end
    expected_textes.each do |str|
      expect(page).to have_content(str), "La page devrait contenir le texte “#{str}”"
    end
  end
end

def ne_peut_pas_atteindre_lespace_personnel
  it "ne peut pas atteindre l'espace personnel du concours" do
    goto("concours/espace_concurrent")
    expect(page).not_to be_espace_personnel
    expect(page).to be_identification_concours
  end
end

def ne_peut_pas_atteindre_le_palmares
  it "ne peut pas atteindre le palmarès du conccours" do
    goto("concours/palmares")
    expect(page).not_to be_palmares_concours(TConcours.current.phase)
    expect(page).to be_identification_concours
  end
end

def peut_rejoindre_la_page_des_palmares
  it "peut atteindre le palmarès du concours de l'année" do
    goto("concours/palmares")
    expect(page).to be_palmares_concours(TConcours.current.phase)
  end
end #/ peut_rejoindre_la_page_des_palmares
