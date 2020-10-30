# encoding: UTF-8
# frozen_string_literal: true

class TConcurrent
  # IN    +data+ table des données, doit contenir :
  #         :titre, :synopsis et optionnellement :auteurs
  #         Le :synopsis est le path ABSOLU du fichier
  # DO    Prend le concurrent en tant que visiteur quelconque, l'identifie,
  #       le conduit à son espace personnel, remplit le formulaire d'envoi
  #       du synopsis et le soumet.
  def come_and_send_synopsis(data)
    identify
    visit("http://localhost/AlwaysData/Icare_2020/concours/espace_concurrent")
    within("form#concours-dossier-form") do
      fill_in("p_titre",    with: data[:titre])
      fill_in("p_auteurs",  with: data[:auteurs]) if data.key?(:auteurs)
      attach_file("p_fichier_candidature", data[:synopsis])
      click_on(UI_TEXTS[:concours_bouton_send_dossier])
    end
  end #/ envoi_son_synopsis
end #/TConcurrent

feature "Dépôt du fichier de candidature" do


  before(:all) do
    require './_lib/_pages_/concours/xrequired/constants'
    require_support('concours')
    degel('concours')
  end

  context 'Quand le concours est en route (step 1)' do

    context 'Un visiteur quelconque' do
      scenario 'ne peut pas déposer de fichier de candidature' do
        implementer(__FILE__,__LINE__)
      end
    end #/context un visiteur quelconque




    context 'Un concurrent inscrit' do
      scenario 'peut déposer son fichier de candidature', only:true do
        # *** Préparation ***
        concurrent = TConcurrent.get_random(without_synopsis: true)
        expect(concurrent.specs[0]).not_to eq "1"
        # *** Test ***
        syno_path = File.expand_path(File.join('.','spec','support','asset','documents','synopsis_concours.pdf'))
        concurrent.come_and_send_synopsis(titre: "À plus d'un titre", synopsis: syno_path)

        # *** Vérifications ***
        # Le document a été déposé avec le bon titre au bon endroit
        # (vérifier aussi la taille)
        path = File.join(concurrent.folder, "#{concurrent.id}-#{ANNEE_CONCOURS_COURANTE}.pdf")
        expect(File).to be_exists(path)
        expect(File.stat(syno_path).size).to eq(File.stat(path).size)
        # Un mail de confirmation a été envoyé au concurrent
        # TODO
        # Les specs de son enregistrement pour le concours ont été modifiée
        concurrent.reset
        expect(concurrent.specs[0..1]).to eq "10"
        # J'ai reçu un mail m'informant de l'envoi du synopsis
        # TODO
        # Une actualité annonce l'envoi du synopsis
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
