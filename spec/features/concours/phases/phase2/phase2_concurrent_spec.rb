# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tests propre au concurrent en phase 2 (présélections)
=end
require_relative '../_required'

feature "EN PHASE 2 (présélections)" do
  require_relative './it_cases.rb'
  before :all do
    degel('concours-phase-2')
    # headless
  end

  context 'Un concurrent courant du concours' do
    before :all do
      @concurrent = TConcurrent.get_random(current:true)
      @concurrent.rejoint_le_concours
      @visitor = @concurrent
    end
    it { peut_rejoindre_son_espace_personnel }
    it { peut_rejoindre_la_page_des_palmares }
    it { ne_peut_pas_atteindre_la_section_evalutation }

  end #/context : un concurrent courant

  context 'Un ancien concurrent qui ne participe pas au concours présent' do
    before :all do
      @concurrent = TConcurrent.get_random(current:false, ancien:true)
      @concurrent.rejoint_le_concours
      @visitor = @concurrent
    end
    it { peut_rejoindre_son_espace_personnel }
    it { peut_rejoindre_la_page_des_palmares }
    it { ne_peut_pas_atteindre_la_section_evalutation }

  end #/ contexte : un ancien concurrent (non participant)
end
