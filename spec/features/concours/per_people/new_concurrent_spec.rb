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

feature "Suivi du concours" do
  context 'pour un nouveau concurrent' do
    before :all do
      @concurrent = TConcurrent.get_random(current:true, ancien:false, femme:true)
    end

    context 'PHASE 0' do
      before :all do
        degel('concours-phase-0')
      end
      it { atteint_lannonce_du_prochain_concours }
      it { ne_peut_pas_atteindre_lespace_personnel }

    end #/context PHASE 0


    context 'PHASE 1', only:true do
      before :all do
        degel('concours-phase-1')
      end

      scenario { ne_peut_pas_sinscrire_au_concours }

    end #/context PHASE 1

    context 'PHASE 2' do
      before :all do
        degel('concours-phase-2')
      end

      scenario 'peut faire ceci' do

      end

    end #/context PHASE 2

    context 'PHASE 3' do
      before :all do
        degel('concours-phase-3')
      end

      scenario 'peut faire ceci' do

      end

    end #/context PHASE 3

    context 'PHASE 5, 8 et 9' do
      before :all do
        degel('concours-phase-5')
      end

      scenario 'peut faire ceci' do

      end

    end #/context PHASE 5, 8 et 9

  end #/ context : simple visiteur quelconque

end
