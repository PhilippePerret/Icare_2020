# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    NOUVEAU CONCURRENT

=end
require_relative './_required'

feature 'Un ancien concurrent (non courant)' do
  before :all do
    headless(false)
  end

  before(:each) do
    @visitor = TConcurrent.get_random(current:false, ancien:true, femme:true)
    @visitor.rejoint_le_concours
  end

  let(:visitor) { @visitor }

  context 'en PHASE 0', phase0:true do
    before :all do
      degel('concours-phase-0')
    end

    peut_rejoindre_le_concours
    peut_sinscrire_au_concours(as = :ancien)
    ne_peut_pas_transmettre_de_dossier
    peut_atteindre_lannonce_du_prochain_concours
    ne_peut_pas_atteindre_lespace_personnel
    ne_peut_pas_atteindre_la_section_evalutation
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :old)
    peut_telecharger_une_ancienne_fiche_de_lecture

  end #/context PHASE 0


  context 'PHASE 1', phase1:true, ancien:'phase1'  do
    before :all do
      degel('concours-phase-1')
    end

    context 'si déjà inscrit au concours courant' do
      before(:each) { make_visitor_current_concurrent(@visitor) }
      after(:all) { degel('concours-phase-1') }
      peut_rejoindre_le_concours
      ne_peut_pas_sinscrire_au_concours("déjà concurrent")
    end

    peut_rejoindre_le_concours
    peut_sinscrire_au_concours(as = :ancien)
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_modifier_ses_preferences_notifications
    peut_modifier_ses_preferences_fiche_de_lecture
    peut_detruire_son_inscription
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :old)
    peut_telecharger_une_ancienne_fiche_de_lecture

  end #/context PHASE 1

  context 'PHASE 2', phase2:true, ancien:'phase2' do
    before :all do
      degel('concours-phase-2')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :old)
    peut_telecharger_une_ancienne_fiche_de_lecture

  end #/context PHASE 2

  context 'PHASE 3', phase3:true, ancien:'phase3' do
    before :all do
      degel('concours-phase-3')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :old)
    peut_telecharger_une_ancienne_fiche_de_lecture

  end #/context PHASE 3

  context 'PHASE 5', phase5:true, ancien:'phase5' do
    before :all do
      degel('concours-phase-5')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :old)
    peut_telecharger_une_ancienne_fiche_de_lecture

  end #/context PHASE 5

  context 'PHASE 8', phase8:true, ancien:'phase8' do
    before :all do
      degel('concours-phase-8')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :old)
    peut_telecharger_une_ancienne_fiche_de_lecture

  end #/context PHASE 8

  context 'PHASE 9', phase9:true, ancien:'phase9' do
    before :all do
      degel('concours-phase-9')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription
    ne_peut_pas_telecharger_sa_fiche_de_lecture(raison = :old)
    peut_telecharger_une_ancienne_fiche_de_lecture

  end #/context PHASE 9

end
