# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    ICARIEN JAMAIS INSCRIT

=end
require_relative './_required'

feature 'Un icarien' do
  before :all do
    headless(false)
  end

  before(:each) do
    @visitor = TUser.get_random(concours:false, admin:false)
    @visitor.rejoint_le_site
  end

  let(:visitor) { @visitor }

  context 'en PHASE 0' do
    before :all do
      degel('concours-phase-0')
    end
    peut_sinscrire_au_concours(as = :icarien)
    # peut_atteindre_lannonce_du_prochain_concours
    # ne_peut_pas_atteindre_lespace_personnel
    # ne_peut_pas_atteindre_la_section_evalutation

  end #/context PHASE 0


  context 'PHASE 1' do
    before :all do
      degel('concours-phase-1')
    end

    context 'si déjà inscrit' do
      before(:all){ degel('concours-phase-1') }
      before(:each) { make_visitor_current_concurrent(@visitor) }
      after(:all){ degel('concours-phase-1') }
      peut_rejoindre_le_concours
      ne_peut_pas_sinscrire_au_concours("déjà inscrit")
    end

    peut_rejoindre_le_concours
    peut_sinscrire_au_concours(as = :icarien)
    # ne_peut_pas_atteindre_la_section_evalutation
    # peut_modifier_ses_preferences_notifications
    # peut_modifier_ses_preferences_fiche_de_lecture
    # ne_peut_pas_transmettre_de_dossier
    # peut_detruire_son_inscription

  end #/context PHASE 1

  context 'PHASE 2' do
    before :all do
      degel('concours-phase-2')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 2

  context 'PHASE 3' do
    before :all do
      degel('concours-phase-3')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 3

  context 'PHASE 5, 8 et 9' do
    before :all do
      degel('concours-phase-5')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 5, 8 et 9

end
