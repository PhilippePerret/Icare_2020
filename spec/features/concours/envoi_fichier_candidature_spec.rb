# encoding: UTF-8
# frozen_string_literal: true
require_relative './_required'

class TConcurrent
  include SpecModuleNavigation
  # IN    +data+ table des données, doit contenir :
  #         :titre, :synopsis et optionnellement :auteurs
  #         Le :synopsis est le path ABSOLU du fichier
  # DO    Prend le concurrent en tant que visiteur quelconque, l'identifie,
  #       le conduit à son espace personnel, remplit le formulaire d'envoi
  #       du synopsis et le soumet.
  def come_and_send_synopsis(data)
    identify
    goto("concours/espace_concurrent")
    within("form#concours-dossier-form") do
      fill_in("p_titre",    with: data[:titre])
      fill_in("p_auteurs",  with: data[:auteurs]) if data.key?(:auteurs)
      attach_file("p_fichier_candidature", data[:synopsis])
      click_on(UI_TEXTS[:concours_bouton_send_dossier])
    end
    screenshot("after-send-fichier-concours")
  end #/ envoi_son_synopsis
end #/TConcurrent

feature "Dépôt du fichier de candidature" do


  before(:all) do
    degel('concours-phase-1')
    TMails.remove_all
    require './_lib/data/secret/phil'
    phil.instance_variable_set("@mail", 'concours@atelier-icare.net')
  end

  after(:all) do
    phil.instance_variable_set("@mail", PHIL_MAIL)
  end

  let(:concurrent) { @concurrent }

  context 'Quand le concours est en route (phase 1)' do

    context 'Un visiteur quelconque' do
      scenario 'ne peut pas déposer de fichier de candidature' do
        goto("concours/espace_concurrent")
        expect(page).not_to have_titre("Espace personnel")
        expect(page).to have_titre("Identification")
      end
    end #/context un visiteur quelconque


    context 'Un ancien concurrent non inscrit' do
      before(:all) do
        @concurrent = TConcurrent.get_random(current: false)
      end
      scenario 'trouve un message l’invitant à s’inscrire' do
        concurrent.identify
        expect(page).to have_titre("Inscription") # on est renvoyé là
        goto("concours/espace_concurrent")
        screenshot("ancien-concurent-espace-personnel")
        expect(page).to have_css("fieldset#concours-fichier-candidature")
        expect(page).not_to have_css("form#concours-dossier-form")
        expect(page).to have_content("Vous devez vous inscrire à la session #{ANNEE_CONCOURS_COURANTE}")
      end
    end

    context 'Un concurrent ayant déjà déposé son fichier' do
      before(:all) do
        @concurrent = TConcurrent.get_random(avec_fichier: true)
      end
      scenario 'trouve un message lui confirmant son dépôt' do
        concurrent.identify
        screenshot("concurrent-with-synopsis")
        expect(page).to have_titre("Espace personnel")
        expect(page).not_to have_css("form#concours-dossier-form")
        expect(page).to have_content("Votre fichier de candidature a bien été transmis.")
      end
    end


    context 'Un concurrent inscrit sans fichier déposé' do
      scenario 'peut déposer son fichier de candidature', only:true do
        # *** Préparation ***
        start_time = Time.now.to_i
        concurrent = TConcurrent.get_random(avec_fichier: false)
        concurrent.reset
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
        expect(concurrent).to have_mail(subject:"[CONCOURS] Réception de votre fichier de candidature", after: start_time)
        # Les specs de son enregistrement pour le concours ont été modifiée
        # J'ai reçu un mail m'informant de l'envoi du synopsis
        expect(phil).to have_mail(subject:"[CONCOURS] Dépôt d'un fichier de candidature", after: start_time)

        concurrent.reset
        expect(concurrent.specs[0..1]).to eq "10"
        # Une actualité annonce l'envoi du synopsis
        expect(TActualites).to be_exists(after:start_time, type:"CONCOURSFILE"),
          "Une actualité devrait annoncer l'envoi du fichier"
      end
    end #/ Context Un concurrent inscrit
  end #/ Context concours en route (phase 1)


  context 'Quand le concours est en phase 2 (préselections en cours)' do
    before(:all) do
      degel('concours-phase-2')
    end
    scenario 'Un concurrent ne peut plus déposer de fichier de candidature'do
      concurrent = TConcurrent.get_random(avec_fichier: false)
      concurrent.identify
      goto("concours/espace_concurrent")
      expect(page).to have_titre("Espace personnel")
      expect(page).to have_no_erreur
      expect(page).not_to have_css("form#concours-dossier-form")
    end
  end

  context 'Quand le concours est en phase 0 (non lancé)'  do
    before(:all) do
      degel('concours-phase-0')
    end
    scenario 'Un concurrent peut rejoindre l’espace personnel, mais pas déposer de fichier de candidature' do
      concurrent = TConcurrent.get_random
      concurrent.identify
      goto("concours/espace_concurrent")
      expect(page).to have_titre("Espace personnel")
      expect(page).not_to have_css("form#concours-dossier-form")
    end
  end

end
