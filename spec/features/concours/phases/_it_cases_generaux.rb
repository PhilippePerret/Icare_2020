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

# Utiliser it { ne_peut_pas_atteindre_la_section_evalutation } pour tester
# que le membre courant ne peut pas atteindre la section d'évaluation
def ne_peut_pas_atteindre_la_section_evalutation
  try_identify_visitor
  goto("concours/evaluation")
  expect(page).not_to be_page_evaluation
  expect(page).to be_indentification_jury
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
