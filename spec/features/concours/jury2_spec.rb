# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    MEMBRE DU SECOND JURY

  Description des phases :

  Commun à toutes les phases :
    - Ne peut jamais s'inscrire

  PHASE 0
    Trouve un simple encart annonçant le concours
  PHASE 1
    Trouve la page d'accueil normale.
  PHASE 2
    Trouve la page d'accueil annonçant les 10 dossiers présélectionnés.
  PHASE 3
    Trouve la page d'accueil annonçant la fin du concours et donc le palmarès.
  PHASE 5, 8 et 9
    Page d'accueil de fin du concours (palmarès).
=end
require_relative './_required'

feature "Un membre du second jury" do
  before(:all) do
  end
  before(:each) do
    @visitor = TEvaluator.get_random(jury:2)
    try_identify_visitor
  end
  context 'en PHASE 0', phase0:true, jury2:'phase0' do
    before :all do
      degel('concours-phase-0')
      headless(false)
    end
    peut_rejoindre_le_concours
    peut_atteindre_lannonce_du_prochain_concours
    ne_peut_pas_sinscrire_au_concours("membre du jury")
  end #/context PHASE 0


  context 'PHASE 1', phase1:true, jury2:'phase1' do
    before :all do
      degel('concours-phase-1')
    end
    peut_rejoindre_le_concours
    ne_peut_pas_encore_evaluer_un_projet
    ne_peut_pas_lire_un_projet(raison = :too_soon)
  end #/context PHASE 1

  context 'PHASE 2', phase2:true, jury2:'phase2' do
    before :all do
      degel('concours-phase-2')
    end
    peut_rejoindre_le_concours
    ne_peut_pas_lire_un_projet(raison = :too_soon)
    ne_peut_pas_encore_evaluer_un_projet
  end #/context PHASE 2

  context 'en PHASE 3', phase3:true, jury2:'phase3' do
    before :all do
      degel('concours-phase-3')
    end
    # peut_rejoindre_le_concours
    peut_lire_un_projet_preselectionned
    # peut_evaluer_un_projet_preselectionned
    # peut_evaluer_un_synopsis_par_la_fiche
    # peut_modifier_son_evaluation
  end #/context PHASE 3

  context 'en PHASE 5', phase5:true, jury2:'phase5' do
    before :all do
      degel('concours-phase-5')
    end
    peut_rejoindre_le_concours
    peut_lire_un_projet
    ne_peut_plus_evaluer_les_projets
  end #/context PHASE 5

  context 'PHASE 8', phase8:true, jury2:'phase8' do
    before :all do
      degel('concours-phase-8')
    end
    peut_rejoindre_le_concours
    peut_lire_un_projet
    ne_peut_plus_evaluer_les_projets
  end #/context PHASE 8

  context 'PHASE 9', phase9:true, jury2:'phase9' do
    before :all do
      degel('concours-phase-9')
    end
    ne_peut_plus_rejoindre_le_concours
  end #/context PHASE 9

end
