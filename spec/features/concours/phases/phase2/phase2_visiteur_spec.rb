# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tests propre à un visiteur quelconque en phase 2 (présélections)
=end
require_relative '../_required'

feature "EN PHASE 2 (présélections)" do
  require_relative './it_cases.rb'
  before :all do
    degel('concours-phase-2')
  end
  context 'Un visiteur quelconque' do
    it { trouve_une_home_page_concours_conforme }
    it { ne_peut_pas_atteindre_la_section_evalutation }
    it { ne_peut_pas_atteindre_le_palmares }
    it { ne_peut_pas_atteindre_lespace_personnel }
  end #/context : un concurrent courant
end
