# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    ICARIEN PAS INSCRIT

=end
require_relative './_required'

feature 'Un icarien' do
  before :all do
    headless(true)
  end

  before(:each) do
    @visitor = TUser.get_random(concours:false, admin:false)
    @visitor.rejoint_le_site
  end

  let(:visitor) { @visitor }

  context 'en PHASE 0', phase0:true do
    before :all do
      degel('concours-phase-0')
    end
    peut_sinscrire_au_concours(as = :icarien)
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 0


  context 'PHASE 1' do
    before :all do
      degel('concours-phase-1')
    end
    peut_sinscrire_au_concours(as = :icarien)
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 1

  context 'PHASE 2' do
    before :all do
      degel('concours-phase-2')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 2

  context 'PHASE 3' do
    before :all do
      degel('concours-phase-3')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 3

  context 'PHASE 5' do
    before :all do
      degel('concours-phase-5')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 5, 8 et 9

  context 'PHASE 8' do
    before :all do
      degel('concours-phase-8')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 5, 8 et 9

  context 'PHASE 9' do
    before :all do
      degel('concours-phase-9')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 5, 8 et 9

end
