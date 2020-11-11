# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce module permet de définir l'affichage de la liste des fiches de lecture
  en fonction de la phase et du visiteur.

  VISITEURS (droits ascendants)
    - quelconque
    - concurrent
    - evaluator de jury 1, evaluator de jury 2
    - administrateur

  PHASES
    - 0 (pas de concours lancé)
    - 1 (concours en route, dépôt possible)
    - 2 (fin échéance, présélection en cours)
    - 3 (présélection faite, sélection finale)
    - 5 (séleciton finale faite, palmarès)

  AFFICHAGES
    - triées par note descendante
    - triées par pourcentage d'évaluation
=end
require_relative './_required'
require_relative './fiches_lectures_per_phase/shared_examples'

def member_jury1
  @member_jury1 ||= TEvaluator.get_random(jury: 1)
end
def member_jury2
  @member_jury2 ||= TEvaluator.get_random(jury: 2)
end
def member_jury3
  @member_jury3 ||= TEvaluator.get_random(jury: 3)
end

feature "La liste des fiches de lecture" do

  before(:all) do
    headless(true)
  end

  context 'en phase 0' do
    before(:all) do
      degel('concours-phase-0')
    end
    context 'un visiteur quelconque' do
      it_behaves_like "un visiteur renvoyé à l’identification"
    end
    context 'un membre du jury 1' do
      it_behaves_like "un juré renvoyé à l'accueil du jury", member_jury1
    end
    context 'un membre du jury 2' do
      it_behaves_like "un juré renvoyé à l'accueil du jury", member_jury2
    end
    context 'un administrateur' do
      before(:all)  { phil.rejoint_le_site }
      after(:all)   { Capybara.reset_sessions! }
      it_behaves_like "un juré renvoyé à l'accueil du jury", phil
    end
  end


  context 'en phase 1' do
    before(:all) do
      degel('concours-phase-1')
    end
    context 'un visiteur quelconque' do
      it_behaves_like "un visiteur renvoyé à l’identification"
    end
    context 'un membre du jury 1', only:true do
      it_behaves_like "un juré autorisé à voir les fiches de lecture", member_jury1
    end
    context 'un membre du jury 2' do
      it_behaves_like "un juré renvoyé à la liste des synopsis", member_jury2
    end
    context 'un administrateur' do
      before(:all)  { phil.rejoint_le_site }
      after(:all)   { Capybara.reset_sessions! }
      it_behaves_like "un juré autorisé à voir les fiches de lecture", phil
    end
  end # contexte : en phase 1


end
