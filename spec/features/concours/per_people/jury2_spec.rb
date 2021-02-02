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
  context 'en PHASE 0', phase0:true do
    before :all do
      degel('concours-phase-0')
      headless(false)
    end
    peut_rejoindre_le_concours
    peut_atteindre_lannonce_du_prochain_concours
    ne_peut_pas_sinscrire_au_concours("membre du jury")
  end #/context PHASE 0


  context 'PHASE 1' do
    before :all do
      degel('concours-phase-1')
    end
    peut_rejoindre_le_concours
  end #/context PHASE 1

  context 'PHASE 2' do
    before :all do
      degel('concours-phase-2')
    end
    peut_rejoindre_le_concours
  end #/context PHASE 2

  context 'PHASE 3' do
    before :all do
      degel('concours-phase-3')
    end
    peut_rejoindre_le_concours
  end #/context PHASE 3

  context 'PHASE 5' do
    before :all do
      degel('concours-phase-5')
    end
    peut_rejoindre_le_concours
  end #/context PHASE 5

  context 'PHASE 8 et 9' do
    before :all do
      degel('concours-phase-8')
    end
    peut_rejoindre_le_concours
  end #/context PHASE 8 et 9

end
