# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    SIMPLE VISITEUR

  Description des phases :

  PHASE 0
    Trouve un simple encart annonçant le concours et permettant de s'inscrire
  PHASE 1
    Trouve la page d'accueil normale. Peut s'inscrire.
  PHASE 2
    Trouve la page d'accueil annonçant les 10 dossiers présélectionnés.
    Ne peut plus s'inscrire.
  PHASE 3
    Trouve la page d'accueil annonçant la fin du concours et donc le palmarès.
    Ne peut plus s'inscrire.
  PHASE 5, 8 et 9
    Page d'accueil de fin du concours (palmarès). Peut s'inscrire à nouveau.
=end
require_relative './_required'

feature "Un administrateur", admin:true do
  before(:all) do
    headless(false)
  end
  before(:each) do
    phil.rejoint_le_site
  end

  context 'PHASE 0', admin:'phase0', phase0:true do
    before :all do
      degel('concours-phase-0')
    end
    peut_atteindre_lannonce_du_prochain_concours
    ne_peut_pas_sinscrire_au_concours("administrateur")
    peut_passer_le_concours_a_la_phase_suivante(1)

  end #/context PHASE 0


  context 'PHASE 1', admin:'phase1', phase1:true do
    before :all do
      degel('concours-phase-1')
    end
    peut_passer_le_concours_a_la_phase_suivante(2)

  end #/context PHASE 1

  context 'PHASE 2', admin:'phase2', phase2:true do
    before :all do
      degel('concours-phase-2')
    end
    peut_passer_le_concours_a_la_phase_suivante(3)

  end #/context PHASE 2

  context 'PHASE 3', admin:'phase3', phase3:true do
    before :all do
      degel('concours-phase-3')
    end
    peut_passer_le_concours_a_la_phase_suivante(5)

  end #/context PHASE 3

  context 'PHASE 5', admin:'phase5', phase5:true do
    before :all do
      degel('concours-phase-5')
    end
    peut_passer_le_concours_a_la_phase_suivante(8)

  end #/context PHASE 5

  context 'PHASE 8', admin:'phase8', phase8:true do
    before :all do
      degel('concours-phase-8')
    end
    peut_passer_le_concours_a_la_phase_suivante(9)
  end #/context PHASE 8


  # context 'PHASE 9', admin:'phase9', phase9:true do
  #   before :all do
  #     degel('concours-phase-8')
  #   end
  #   peut_passer_le_concours_a_la_phase_suivante(9)
  # end #/context PHASE 9

end
