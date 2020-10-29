# encoding: UTF-8
# frozen_string_literal: true

feature "Dépôt du fichier de candidature" do

  context 'Quand le concours est en route (step 1)' do



    context 'Un visiteur quelconque' do
      scenario 'ne peut pas déposer de fichier de candidature' do
        implementer(__FILE__,__LINE__)
      end
    end #/context un visiteur quelconque




    context 'Un concurrent inscrit' do
      scenario 'peut déposer son fichier de candidature' do

        # *** Vérifications préliminaires ***
        # TODO

        # Un mail est envoyé au concurrent pour confirmer son envoi
        # TODO

        # Un mail est envoyé à l'administration pour confirmer, qui contient
        # l'auteur et les références du fichier. Contient aussi la commande
        # pour charger (downloader) le fichier
        # TODO
      end
    end #/ Context Un concurrent inscrit
  end #/ Context concours en route (step 1)


  context 'Quand le concours est en phase 2' do
    scenario 'Personne ne peut déposer de fichier de candidature' do
      implementer(__FILE__,__LINE__)
    end
  end

  context 'Quand le concours est en phase autre que 1' do
    scenario 'Personne ne peut déposer de fichier de candidature' do
      implementer(__FILE__,__LINE__)
    end
  end

end
