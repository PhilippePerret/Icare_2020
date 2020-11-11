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

def member_jury1
  @member_jury1 ||= TEvaluator.get_random(jury: 1)
end
def member_jury2
  @member_jury2 ||= TEvaluator.get_random(jury: 2)
end
def member_jury3
  @member_jury3 ||= TEvaluator.get_random(jury: 3)
end

RSpec.shared_examples "un visiteur renvoyé à l’identification" do
  it 'est renvoyé à l’identification' do
    goto("concours/evaluation?view=fiches_lecture")
    expect(page).not_to be_fiches_lecture
    expect(page).to be_identification_evaluator
  end
end
RSpec.shared_examples "un visiteur renvoyé à l'accueil du jury" do |visitor|
  it 'est renvoyé à l’accueil du concours' do
    visitor.rejoint_le_concours if visitor.is_a?(TEvaluator)
    goto("concours/evaluation?view=fiches_lecture")
    expect(page).not_to be_fiches_lecture
    expect(page).to be_accueil_jury
    visitor.se_deconnecte if visitor.is_a?(TEvaluator)
    screenshot("deconnexion-membre-jury")
  end
end

RSpec.shared_examples "un membre autorisé à voir les fiches de lecture" do |visitor|
  it 'peut voir les fiches de lecture avec ses notes personnelles' do
    visitor.rejoint_le_concours if visitor.is_a?(TEvaluator)
    goto("concours/evaluation?view=fiches_lecture")
    expect(page).to be_fiches_lecture
    pending("Vérifier que les notes soient bien les notes de l'évaluator")
    # TODO
    pending("Vérifier que l'ordre de classement soit bien celui qui dépend des notes du membre courant")
    # TODO
    visitor.se_deconnecte if visitor.is_a?(TEvaluator)
    screenshot("deconnexion-membre-jury")
  end
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
      it_behaves_like "un visiteur renvoyé à l'accueil du jury", member_jury1
    end
    context 'un membre du jury 2' do
      it_behaves_like "un visiteur renvoyé à l'accueil du jury", member_jury2
    end
    context 'un administrateur', only:true do
      before(:all)  { phil.rejoint_le_site }
      after(:all)   { Capybara.reset_sessions! }
      it_behaves_like "un visiteur renvoyé à l'accueil du jury", phil
    end
  end


  context 'en phase 1' do
    before(:all) do
      degel('concours-phase-1')
    end
    context 'un visiteur quelconque' do
      it_behaves_like "un visiteur renvoyé à l’identification"
    end
    context 'un membre du jury 1' do
      it_behaves_like "un visiteur autorisé à voir les fiches de lecture", member_jury1
    end
    context 'un membre du jury 2' do
      it_behaves_like "un visiteur renvoyé à l'accueil du jury", member_jury2
    end
    context 'un administrateur', only:true do
      before(:all)  { phil.rejoint_le_site }
      after(:all)   { Capybara.reset_sessions! }
      it_behaves_like "un visiteur renvoyé à l'accueil du jury", phil
    end
  end # contexte : en phase 1


end
