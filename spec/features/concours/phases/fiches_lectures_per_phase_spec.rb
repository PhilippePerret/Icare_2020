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

def visitor
  @visitor ||= TUser.get(9)
end
def member_jury1
  @member_jury1 ||= TEvaluator.get_random(jury: 1)
end
def member_jury2
  @member_jury2 ||= TEvaluator.get_random(jury: 2)
end
def member_jury3
  @member_jury3 ||= TEvaluator.get_random(jury: 3)
end

feature "Quand on veut atteindre la liste des fiches de lecture" do

  before(:all) do
    # headless(true)
  end

  def goto_fiches_on_phase_with(phase, visitor = nil)
    degel("concours-phase-#{phase}")
    if not(visitor.nil?)
      if visitor.respond_to?(:rejoint_le_concours)
        visitor.rejoint_le_concours
      elsif visitor.respond_to?(:rejoint_le_site)
        visitor.rejoint_le_site
      else
        raise "Je ne connais pas la méthode pour connecter #{visitor.pseudo}…"
      end
    end
    goto("concours/evaluation?view=fiches_lecture")
  end #/ goto_fiches_on_phase_with

  context 'pour un visiteur quelconque' do
    subject { visitor }
    context 'en phase 0' do
      before { goto_fiches_on_phase_with(0) }
      it { is_expected.to be_redirect_to(:jury_identification) }
    end
    context 'en phase 1' do
      before { goto_fiches_on_phase_with(1) }
      it { is_expected.to be_redirect_to(:jury_identification) }
    end
    context 'en phase 2' do
      before { goto_fiches_on_phase_with(2) }
      it { is_expected.to be_redirect_to(:jury_identification) }
    end
    context 'en phase 3' do
      before { goto_fiches_on_phase_with(3) }
      it { is_expected.to be_redirect_to(:jury_identification) }
    end
    context 'en phase 5' do
      before { goto_fiches_on_phase_with(5) }
      it { is_expected.to be_redirect_to(:jury_identification) }
    end
    context 'en phase 8' do
      before { goto_fiches_on_phase_with(8) }
      it { is_expected.to be_redirect_to(:jury_identification) }
    end
    context 'en phase 9' do
      before { goto_fiches_on_phase_with(9) }
      it { is_expected.to be_redirect_to(:jury_identification) }
    end
  end

  context 'pour un membre du premier jury (présélections)', only:true do
    subject { member_jury1 }
    context 'en phase 0' do
      before { goto_fiches_on_phase_with(0, subject) }
      it { is_expected.to be_redirect_to(:accueil_jury_concours) }
    end
    context 'en phase 1' do
      # EN phase 1, un membre du premier jury doit voir les fiches de lecture
      # avec seulement sa note à lui.
      before { goto_fiches_on_phase_with(1, subject) }
      it { is_expected.to be_on_page(:fiches_synopsis) }
      it 'peut afficher les fiches de lecture avec ses notes' do
        find(".usefull-links").hover
        member_jury1.click_on("Fiches de lecture")
        is_expected.to be_on_page(:fiches_lectures)
      end
    end
  end

  context 'en phase 0' do
    before(:all) do
      degel('concours-phase-0')
    end
    before(:each) do
      goto("concours/evalutation?view=fiches_lecture")
    end

    # context 'un membre du jury 1' do
    #   it_behaves_like "un juré renvoyé à l'accueil du jury", member_jury1
    # end
    # context 'un membre du jury 2' do
    #   it_behaves_like "un juré renvoyé à l'accueil du jury", member_jury2
    # end
    # context 'un administrateur' do
    #   before(:all)  { phil.rejoint_le_site }
    #   after(:all)   { Capybara.reset_sessions! }
    #   it_behaves_like "un juré renvoyé à l'accueil du jury", phil
    # end
  end


  context 'en phase 1' do
    before(:all) do
      degel('concours-phase-1')
    end
    # context 'un visiteur quelconque' do
    #   it_behaves_like "un visiteur renvoyé à l’identification"
    # end
    # context 'un membre du jury 1' do
    #   it_behaves_like "un juré autorisé à voir les fiches de lecture", member_jury1
    # end
    # context 'un membre du jury 2' do
    #   it_behaves_like "un juré renvoyé à la liste des synopsis", member_jury2
    # end
    # context 'un administrateur' do
    #   before(:all)  { phil.rejoint_le_site }
    #   after(:all)   { Capybara.reset_sessions! }
    #   it_behaves_like "un juré autorisé à voir les fiches de lecture", phil
    # end
  end # contexte : en phase 1


end
