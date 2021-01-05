# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tous les IT-CASES pour la fiche de lecture
=end

def peut_telecharger_sa_fiche_de_lecture
  it "peut telecharger sa fiche de lecture" do
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expect(page).to have_link("TÉLÉCHARGER LA FICHE DE LECTURE")
    pending "à poursuivre (télécharger la fiche)"
  end
end #/

def ne_peut_pas_telecharger_sa_fiche_de_lecture
  it "ne peut pas telecharger sa fiche de lecture" do
    goto("concours/espace_concurrent")
    expect(page).to be_espace_personnel
    expect(page).not_to have_link("TÉLÉCHARGER LA FICHE DE LECTURE")
    pending "à implémenter (échec par lien direct)"
  end
end #/
