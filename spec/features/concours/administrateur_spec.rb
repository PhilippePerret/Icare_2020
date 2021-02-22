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
  end #/context PHASE 0

  context 'PHASE 0 à 1', admin:'phase0', phase0:true do
    before :all do
      degel('concours-phase-0')
    end
    peut_passer_le_concours_a_la_phase_suivante(1)
  end #/context PHASE 0

  context 'PHASE 1', admin:'phase1', phase1:true do
    before :all do
      degel('concours-phase-1')
    end
    let(:concurrent_courant) { TConcurrent.get_random(avec_fichier:true, conformite_definie:false, current:true) }
    context 'avant la limite d’échéance' do
      peut_refuser_un_dossier_pour_non_conformite
    end

    # # Je ne sais pas tester ça
    # context 'après la limite d’échéance' do
    #   before :all do
    #     ENV['TESTS_TIME_NOW'] = Time.new(ANNEE_CONCOURS_COURANTE,3,1,0,0,0).to_i.to_s
    #   end
    #   peut_refuser_un_dossier_pour_non_conformite(true)
    # end

  end

  context 'PHASE 1 à 2', admin:'phase1a2', phase1:true do
    before :all do
      degel('concours-phase-1')
    end
    peut_passer_le_concours_a_la_phase_suivante(2)
  end #/context PHASE 1

  context 'PHASE 2', admin:'phase2', phase2:true do
    before :all do
      degel('concours-phase-2')
    end
    peut_rejoindre_la_page_des_palmares
  end

  context 'PHASE 2 à 3', admin:'phase2a3', phase2:true do
    before :all do
      degel('concours-phase-2')
    end
    peut_passer_le_concours_a_la_phase_suivante(3)
  end

  context 'PHASE 3', admin:'phase3', phase3:true do
    before :all do
      degel('concours-phase-3')
    end

    peut_atteindre_la_page_devaluation
    peut_rejoindre_la_page_des_palmares

  end #/context PHASE 3

  context 'PHASE 3 à 4' do
    before(:all) do
      degel('concours-phase-3')
    end
    peut_passer_le_concours_a_la_phase_suivante(5)
  end

  context 'PHASE 5', admin:'phase5', phase5:true do
    before :all do
      degel('concours-phase-5')
    end

  end

  context 'PHASE 5 à 8', admin:'phase5', phase5:true do
    before :all do
      degel('concours-phase-5')
    end
    peut_passer_le_concours_a_la_phase_suivante(8)

  end #/context PHASE 5

  context 'PHASE 8', admin:'phase8', phase8:true do
    before :all do
      degel('concours-phase-8')
    end
  end #/context PHASE 8

  context 'PHASE 8 à 9', admin:'phase8', phase8:true do
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
