# encoding: UTF-8
# frozen_string_literal: true
=begin
  Test de toutes les phases du concours pour un :

    NOUVEAU CONCURRENT

  Description des phases :

  PHASE 0
    Trouve un simple encart annonçant le concours et permettant de s'inscrire
    Il peut s'inscrire et le fait.
  PHASE 1
    Trouve la page d'accueil normale.
    Il peut s'inscrire et le fait.
  PHASE 2
    Trouve la page d'accueil annonçant les 10 dossiers présélectionnés.
    Il ne peut plus s'inscrire.
  PHASE 3
    Trouve la page d'accueil annonçant la fin du concours et donc le palmarès.
    Ne peut plus s'inscrire.
  PHASE 5, 8 et 9
    Page d'accueil de fin du concours (palmarès).
    Peut s'inscrire à nouveau et le fait.
=end
require_relative './_required'

feature 'Un ancien concurrent' do
  before :all do
    headless
  end

  let(:visitor) { @visitor ||= begin
    puts "J'initialise un ancien concurrent"
    TConcurrent.get_random(current:false, ancien:true, femme:true)
  end }

  context 'en PHASE 0' do
    before :all do
      degel('concours-phase-0')
    end
    peut_atteindre_lannonce_du_prochain_concours
    ne_peut_pas_sinscrire_au_concours
    ne_peut_pas_atteindre_lespace_personnel
    ne_peut_pas_atteindre_la_section_evalutation
    ne_peut_pas_sinscrire_au_concours

  end #/context PHASE 0


  context 'PHASE 1' do
    before :all do
      degel('concours-phase-1')
    end

    ne_peut_pas_atteindre_la_section_evalutation
    ne_peut_pas_sinscrire_au_concours
    peut_modifier_ses_preferences_notifications
    peut_modifier_ses_preferences_fiche_de_lecture
    ne_peut_pas_transmettre_de_dossier
    peut_detruire_son_inscription

  end #/context PHASE 1

  context 'PHASE 2' do
    before :all do
      degel('concours-phase-2')
    end
    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 2

  context 'PHASE 3' do
    before :all do
      degel('concours-phase-3')
    end

    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 3

  context 'PHASE 5, 8 et 9' do
    before :all do
      degel('concours-phase-5')
    end

    ne_peut_pas_transmettre_de_dossier
    ne_peut_pas_atteindre_la_section_evalutation
    peut_detruire_son_inscription

  end #/context PHASE 5, 8 et 9

end
