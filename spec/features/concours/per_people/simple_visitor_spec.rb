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

feature "Un simple visiteur" do
  before(:all) do
    headless(false)
  end
  context 'en PHASE 0' do
    before :all do
      degel('concours-phase-0')
    end
    peut_atteindre_lannonce_du_prochain_concours
    peut_sinscrire_au_concours(as = :simple)
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 0


  context 'PHASE 1' do
    before :all do
      degel('concours-phase-1')
    end
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 1

  context 'PHASE 2' do
    before :all do
      degel('concours-phase-2')
    end
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 2

  context 'PHASE 3' do
    before :all do
      degel('concours-phase-3')
    end
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 3

  context 'PHASE 5' do
    before :all do
      degel('concours-phase-5')
    end
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 5

  context 'PHASE 8 et 9' do
    before :all do
      degel('concours-phase-8')
    end
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 8 et 9

end
