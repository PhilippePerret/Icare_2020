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
    expect(page).not_to be_page_erreur
    expect(page).to be_accueil_concours(0)
  end
end

def atteint_la_page_daccueil_du_concours(phase)
  it "peut atteindre la page d'accueil du concours" do
    try_identify_visitor
    goto("concours")
    expect(page).not_to be_page_erreur
    expect(page).to be_accueil_concours(phase)
  end
end #/ atteint_la_page_daccueil_du_concours

def peut_rejoindre_toutes_les_sections_depuis_laccueil
  def revenir_accueil; click_on("Le Concours") end
  it "peut rejoindre toutes les sections depuis l’accueil" do
    visitor&.logout
    goto("concours/accueil")
    expect(page).not_to be_page_erreur
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
  it "peut atteindre la page des palmarès des concours" do
    goto("concours/palmares")
    screenshot("page-palmares-phase-#{TConcours.current.phase}")
    expect(page).not_to be_page_erreur
    expect(page).to be_palmares_concours
  end

  it "trouve une page de palmarès conforme" do
    require './_lib/_pages_/concours/xmodules/calculs/Dossier'
    if TConcours.current.phase > 1
      palmares_path = Dossier.palmares_file_path(ANNEE_CONCOURS_COURANTE)
      expect(File).to be_exists(palmares_path), "Le fichier #{palmares_path} devrait exister…"
      palmares_data = YAML.load_file(palmares_path)
    end
    goto("concours/palmares")
    screenshot("page-palmares-phase-#{TConcours.current.phase}")
    # Inspection minimale (titre et sous-titre)
    expect(page).not_to be_page_erreur
    expect(page).to be_palmares_concours
    # Inspection plus profonde en fonction de la phase
    case TConcours.current.phase
    when 0, 1
      # Pas encore de résultats
      expect(page).to have_content("Le concours est en cours, il n’y a pas encore de résultats.")
    when 2
      expect(page).to have_content("Les présélections sont en cours, les résultats seront affichés très prochainement")
    when 3
      # Liste des présélectionnés + Liste des refusés avec leur score
      expect(page).to have_content("Les projets présélectionnés pour la finale sont")
      expect(page).to have_css('ul#preselecteds')
      expect(page).to have_css('ul#nonselecteds')
      palmares_data[:classement].each_with_index do |dconc, idx|
        conc = TConcurrent.get(dconc[:concurrent_id])
        projet = conc.projet
        conteneur = idx < 10 ? 'ul#preselecteds' : 'ul#nonselecteds'
        index = 1 + (idx < 10 ? idx : idx - 10)
        liconc = conteneur.find("li.nth-of-type(#{index})")
        expect(liconc).to have_content(conc.patronyme.patronize), "La ligne devrait présenter un patronyme correct"
        expect(liconc).to have_content("“#{projet.titre}”"), "La ligne devrait présenter le titre du projet"
        expect(liconc).to have_content(dconc[:note]), "La ligne devrait présenter la note obtenue"
        expect(liconc).to have_css('span', {class:'position', text: 1 + idx}), "La ligne devrait présenter le classement"
      end
    else
      # Liste des lauréats + liste intégrale des scores et placements
      expect(page).to have_content("Les Lauréats du Concours de Synopsis de l’atelier Icare session #{ANNEE_CONCOURS_COURANTE} sont")
    end
  end

  it "peut voir le palmarès d'une autre année" do
    pending "à implémenter"
  end
end
