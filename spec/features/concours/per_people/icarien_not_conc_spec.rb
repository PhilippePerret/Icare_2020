# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    ICARIEN PAS INSCRIT

=end
require_relative './_required'

feature 'Un icarien' do
  before :all do
    headless(false)
  end

  before(:each) do
    @visitor = TUser.get_random(concours:false, pseudo:'Élie', admin:false)
    @visitor.rejoint_le_site
  end

  let(:visitor) { @visitor }

  context 'en PHASE 0', phase0:true, icarien:'phase0' do
    before :all do
      degel('concours-phase-0')
    end
    peut_sinscrire_au_concours(as = :icarien)
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 0


  context 'PHASE 1', phase1:true, icarien:'phase1' do
    before :all do
      degel('concours-phase-1')
    end
    peut_sinscrire_au_concours(as = :icarien)
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 1

  context 'PHASE 2', phase2:true, icarien:'phase2' do
    before :all do
      degel('concours-phase-2')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    peut_detruire_son_inscription
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 2

  context 'PHASE 3', phase3:true, icarien:'phase3' do
    before :all do
      degel('concours-phase-3')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 3

  context 'PHASE 5', phase5:true, icarien:'phase5' do
    before :all do
      degel('concours-phase-5')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 5, 8 et 9

  context 'PHASE 8', phase8:true, icarien:'phase8' do
    before :all do
      degel('concours-phase-8')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 5, 8 et 9

  context 'PHASE 9', phase9:true, icarien:'phase9' do
    before :all do
      degel('concours-phase-9')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation
  end #/context PHASE 5, 8 et 9

end
