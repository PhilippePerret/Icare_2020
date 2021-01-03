# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthodes d'expectation générales, utilisables pour toutes les phases

  Dans le before :all (ou :each), on définit la personne qui visite par
  @member ou @concurrent et ensuite on met le nom des méthodes dans des it :

  context 'qui ?'
    it { le_nom_de_la_methode_dexpectation }
  end

  Par exemple :

  before :all do
    @concurrent = TConcurrent.get_random(current: true)
  end

  context 'un concurrent courant identifié'
    before :each do
      @concurrent.rejoint_le_concours
    end
    it { peut_rejoindre_son_espace_personnel }
  end

=end

def visitor ; @visitor end
def member ; @member end
def concurrent ; @concurrent end
def annee ; ANNEE_CONCOURS_COURANTE end

# Méthode à appeler avant les tests où il faut que le visiteur soit
# identifié.
def try_identify_visitor
  if visitor.is_a?(TConcurrent)
    visitor.rejoint_le_concours
  elsif visitor.is_a?(TEvaluator)
    visitor.rejoint_le_concours
  end
end #/ try_identify_visitor


def peut_sinscrire_au_concours
  require './_lib/_pages_/concours/inscription/constants'
  goto("concours/inscription")
  expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
  expect(page).to have_css("form#concours-signup-form")
  pseudo_concurrent = "Concurrent #{Time.now.to_i}"
  concurrent_mail   = "#{pseudo_concurrent.downcase.gsub(/ /,'')}@philippeperret.fr"
  within("form#concours-signup-form") do
    fill_in("p_patronyme", with: pseudo_concurrent)
    fill_in("p_mail", with: concurrent_mail)
    fill_in("p_mail_confirmation", with: concurrent_mail)
    select("féminin", from: "p_sexe")
    check("p_reglement")
    check("p_fiche_lecture")
    click_on(UI_TEXTS[:concours_bouton_signup])
  end
  expect(page).to have_titre(UI_TEXTS[:concours_titre_participant])
  # Les données sont justes, dans la table des concurrents
  dc = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE patronyme = ?", [pseudo_concurrent]).first
  expect(dc).not_to eq(nil), "Les informations du concurrent auraient dû être enregistrées dans la base"
  concurrent_id = dc[:concurrent_id]
  expect(dc[:mail]).to eq(concurrent_mail)
  expect(dc[:sexe]).to eq("F")
  expect(dc[:options][0]).to eq("1")
  expect(dc[:options][1]).to eq("1") # fiche de lecture

  # Les données sont justes, dans la table des concours
  dcc = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ? and annee = ?", [concurrent_id, ANNEE_CONCOURS_COURANTE]).first
  expect(dcc).not_to eq(nil), "La donnée aurait dû être enregistrée dans la base de données"
end #/

# Dans ce test, le visiteur (@visitor) essaie par tous les moyens possibles
# de s'inscrire (alors qu'il l'est déjà ou que ça n'est pas le moment)
def ne_peut_pas_sinscrire_au_concours
  require './_lib/_pages_/concours/inscription/constants'
  try_identify_visitor
  goto("concours/inscription")
  expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
  sleep 30
end #/ne_peut_pas_sinscrire_au_concours


# Teste si le visiteur (quelconque, concurrent, juré ou non) atteint bien
# la simple annonce du concours, en phase 0, qui permet aussi de s'inscrire.
def atteint_lannonce_du_prochain_concours
  try_identify_visitor
  goto("concours")
  expect(page).to be_page_annonce_concours
end #/ atteint_lannonce_du_prochain_concours

def atteint_la_page_daccueil_du_concours(phase)
  try_identify_visitor
  goto("concours")
  expect(page).to be_accueil_concours(phase)
end #/ atteint_la_page_daccueil_du_concours

# Utiliser it { ne_peut_pas_atteindre_la_section_evalutation } pour tester
# que le membre courant ne peut pas atteindre la section d'évaluation
def ne_peut_pas_atteindre_la_section_evalutation
  try_identify_visitor
  goto("concours/evaluation")
  expect(page).not_to be_page_evaluation
  expect(page).to be_identification_evaluator
end

def peut_rejoindre_son_espace_personnel
  try_identify_visitor
  goto("concours/espace_concurrent")
  expect(page).to be_espace_personnel
end

def ne_peut_pas_atteindre_lespace_personnel
  try_identify_visitor
  goto("concours/espace_concurrent")
  expect(page).not_to be_espace_personnel
  expect(page).to be_identification_concours
end

def ne_peut_pas_atteindre_le_palmares
  try_identify_visitor
  goto("concours/palmares")
  expect(page).not_to be_palmares_concours(TConcours.current.phase)
  expect(page).to be_identification_concours
end

def peut_rejoindre_la_page_des_palmares
  try_identify_visitor
  goto("concours/palmares")
  expect(page).to be_palmares_concours(TConcours.current.phase)
end #/ peut_rejoindre_la_page_des_palmares
