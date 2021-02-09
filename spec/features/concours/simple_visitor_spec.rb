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

feature "Un simple visiteur", visitor:true do
  before(:all) do
    headless(false)
  end
  context 'en PHASE 0', phase0:true, visitor:'phase0' do
    before :all do
      degel('concours-phase-0')
    end
    peut_atteindre_lannonce_du_prochain_concours
    peut_sinscrire_au_concours(as = :simple)
    ne_peut_pas_sinscrire_au_concours_avec_des_donnees_erronnees
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 0


  context 'PHASE 1', phase1:true, visitor:'phase1' do
    before :all do
      degel('concours-phase-1')
    end
    peut_rejoindre_toutes_les_sections_depuis_laccueil
    peut_sinscrire_au_concours(as = :simple)
    ne_peut_pas_sinscrire_au_concours_avec_des_donnees_erronnees
    ne_peut_pas_transmettre_de_dossier
end #/context PHASE 1

  context 'PHASE 2', phase2:true, visitor:'phase2' do
    before :all do
      degel('concours-phase-2')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours][:en_cours_de_preselection])
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 2

  context 'PHASE 3', phase3:true, visitor:'phase3' do
    before :all do
      degel('concours-phase-3')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 3

  context 'PHASE 5', phase5:true, visitor:'phase5' do
    before :all do
      degel('concours-phase-5')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 5

  context 'PHASE 8', phase8:true, visitor:'phase8' do
    before :all do
      degel('concours-phase-8')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 8

  context 'PHASE 9', phase9:true, visitor:'phase9' do
    before :all do
      degel('concours-phase-9')
    end
    ne_peut_pas_sinscrire_au_concours(MESSAGES[:concours_en_cours])
    ne_peut_pas_transmettre_de_dossier
  end #/context PHASE 9

end
