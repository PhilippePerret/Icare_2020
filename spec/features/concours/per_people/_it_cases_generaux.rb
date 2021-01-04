# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthodes d'expectation générales, utilisables pour toutes les phases

  Dans le before :all (ou :each), on définit la personne qui visite par
  @member ou @concurrent et ensuite on met le nom des méthodes dans des it :

  context 'qui ?'
    le_nom_de_la_methode
  end

  Par exemple :

  before :all do
    @concurrent = TConcurrent.get_random(current: true)
  end

  context 'un concurrent courant identifié'
    before :each do
      @concurrent.rejoint_le_concours
    end
    peut_rejoindre_son_espace_personnel
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
  scenario "peut s'inscrire au concours" do
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
  end
end

# Dans ce test, le visiteur (@visitor) essaie par tous les moyens possibles
# de s'inscrire (alors qu'il l'est déjà)
def ne_peut_pas_sinscrire_au_concours(raison_affichee = "déjà concurrent")
  it "ne peut pas s'inscrire au concours (#{raison_affichee})" do
    require './_lib/_pages_/concours/inscription/constants'
    goto("concours/inscription")
    expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
    within("form#concours-signup-form") do
      fill_in("p_patronyme", with: visitor.pseudo)
      fill_in("p_mail", with: visitor.mail)
      fill_in("p_mail_confirmation", with: visitor.mail)
      select("féminin", from: "p_sexe")
      check("p_reglement")
      check("p_fiche_lecture")
      click_on(UI_TEXTS[:concours_bouton_signup])
    end
    expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant]),
      "La page ne devrait pas avoir le titre de confirmation de la participation"
    expect(page).to have_content(raison_affichee)
  end
end #/ne_peut_pas_sinscrire_au_concours
