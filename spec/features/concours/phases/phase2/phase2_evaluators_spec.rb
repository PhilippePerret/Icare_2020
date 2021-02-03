# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tests des évaluateurs en phase 2
=end
require_relative '../_required'

# On requiert les méthodes de la phase 1 qui permettait déjà à l'évaluateur
# de travailler
require_relative '../phase1/it_cases.rb'

feature "En PHASE 2" do
  before(:all) do
    degel('concours-phase-2')
    require './_lib/_pages_/concours/evaluation/lib/constants'
    DATA_QUESTIONS = YAML.load_file(DATA_QUESTIONS_CONCOURS)
  end
  let(:member) { @member }
  let(:fiche_evaluation) { @fiche_evaluation ||= member.fiche_evaluation(concurrent) }
  let(:concurrent) { @concurrent }
  let(:synopsis_id) { @synopsis_id = "#{concurrent.id}-#{annee}" }

  context 'un évaluateur du jury 1 (aka membre du jury)' do
    before :all do
      @concurrent = TConcurrent.find(avec_fichier_conforme: true).shuffle.shuffle.first
      @member = TEvaluator.get_random(fiche_evaluation: @concurrent, jury: 1)
    end
    it { peut_modifier_son_evaluation }
    it { peut_evaluer_un_synopsis_par_le_minichamp }
  end

  context 'un évaluator du second jury' do
    before :all do
      @concurrent = TConcurrent.find(avec_fichier_conforme: true).shuffle.shuffle.first
      @member = TEvaluator.get_random(fiche_evaluation: @concurrent, jury: 2)
    end
    it { ne_peut_pas_atteindre_la_section_evalutation }
  end
end
