# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    ICARIEN JAMAIS INSCRIT

=end
require_relative './_required'

feature 'Un icarien inscrit au concours courant' do
  before :all do
    headless(false)
  end

  before(:each) do
    @visitor = TUser.get_random(concours:true, admin:false, pseudo:'Élie')
    @visitor.rejoint_le_site
  end

  context 'en PHASE 0', phase0:true, icnewconc:'phase0' do
    before :all do
      degel('concours-phase-0')
    end
    ne_peut_pas_sinscrire_au_concours("déjà inscrit")
    peut_atteindre_lannonce_du_prochain_concours
    ne_peut_pas_atteindre_lespace_personnel
    ne_peut_pas_atteindre_la_section_evalutation

  end #/context PHASE 0


  context 'PHASE 1', phase1:true, icnewconc:'phase1' do
    before :all do
      degel('concours-phase-1')
    end

    ne_peut_pas_sinscrire_au_concours("déjà inscrit")

    peut_rejoindre_le_concours
    peut_rejoindre_toutes_les_sections_depuis_laccueil
    peut_modifier_ses_preferences_notifications
    peut_modifier_ses_preferences_fiche_de_lecture

    context 'qui n’a pas encore transmis son dossier' do
      before(:each){ visitor.as_concurrent.destroy_fichier } # au cas où
      peut_transmettre_son_dossier
    end

    context 'qui a déjà transmis son fichier' do
      before(:each){ visitor.as_concurrent.make_fichier_conforme }
      ne_peut_pas_transmettre_de_dossier
    end

    peut_detruire_son_inscription

    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation

  end #/context PHASE 1

  context 'PHASE 2', phase2:true, icnewconc:'phase2' do
    before :all do
      degel('concours-phase-2')
    end

    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours][:en_cours_de_preselection])
    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    peut_detruire_son_inscription

    # --- Sections interdites ---
    ne_peut_pas_atteindre_la_section_evalutation

  end #/context PHASE 2

  context 'PHASE 3', phase3:true, icnewconc:'phase3' do
    before :all do
      degel('concours-phase-3')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 3

  context 'PHASE 5', phase5:true, icnewconc:'phase5' do
    before :all do
      degel('concours-phase-5')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 5

  context 'PHASE 8', phase8:true, icnewconc:'phase8' do
    before :all do
      degel('concours-phase-8')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 8

  context 'PHASE 9', phase9:true, icnewconc:'phase9' do
    before :all do
      degel('concours-phase-9')
    end

    peut_rejoindre_le_concours
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 9

end
