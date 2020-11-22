# encoding: UTF-8
# frozen_string_literal: true
require_relative '../_required'
=begin
  Tests des évaluateurs en phase 1

  En phase 1, c'est-à-dire quand le concours est ouvert et que les
  concurrents peuvent s'inscrire, un évaluateur peut déjà consulter et
  évaluer un synopsis qui aurait déjà été déposé.
=end
require 'yaml'
require 'json'

feature "ÉVALUATEUR EN PHASE 1 DU CONCOURS" do
  before(:all) do
    # headless()
    degel('concours-phase-1')
    require './_lib/_pages_/concours/evaluation/lib/constants'
    DATA_QUESTIONS = YAML.load_file('./_lib/_pages_/concours/evaluation/data/data_evaluation.yaml')
    # puts "DATA_QUESTIONS: #{DATA_QUESTIONS}"
    @concurrent = TConcurrent.find(avec_fichier_conforme: true).shuffle.shuffle.first
    @member = TEvaluator.get_random(fiche_evaluation: @concurrent, jury: 1)
  end
  let(:member) { @member }
  let(:fiche_evaluation) { @fiche_evaluation ||= member.fiche_evaluation(concurrent) }
  let(:concurrent) { @concurrent }
  let(:synopsis_id) { @synopsis_id = "#{concurrent.id}-#{annee}" }
  let(:annee) { ANNEE_CONCOURS_COURANTE }

  context 'un vrai évaluateur' do
    it { peut_evaluer_un_synopsis_par_la_fiche }
    it { peut_modifier_son_evaluation }
    it { peut_evaluer_un_synopsis_par_le_minichamp }
  end

end
