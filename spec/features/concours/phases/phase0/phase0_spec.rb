# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tests pour s'assurer que la phase 0 est correcte pour tout le monde
  Dans cette phase, le prochain concours n'est pas encore lancé.
=end
require_relative "../_required"

feature "Concours de Synopsis - PHASE 0" do
  before :all do
    require './_lib/_pages_/concours/espace_concurrent/constants'
    degel('concours-phase-0')
    headless(false)
  end
  context 'un visiteur quelconque' do
    it 'trouve une page d’accueil minimale valide' do
      goto("concours")
      screenshot("accueil-concours-phase0-visitor")
      expect(page).to be_accueil_concours
      expect(page).to have_content("Le prochain concours de synopsis de l'atelier Icare n'est pas encore lancé.")
      expect(page).to have_link("vous inscrire")
    end

    it 'ne peut pas se rendre sur la page du palmarès' do
      goto("concours/palmares")
      expect(page).not_to be_palmares_concours
      expect(page).to be_accueil_concours
      expect(page).to have_message("Aucun concours en route. Le palmarès n'est pas consultable.")
      expect(page).to have_link("vous inscrire")
    end

    it 'ne peut pas atteindre l’espace personnel' do
      goto("concours/espace_concurrent")
      expect(page).not_to be_espace_personnel
      expect(page).to be_identification_concours
    end

    it 'peut tout à fait s’inscrire pour la prochaine session' do
      goto("concours")
      expect(page).to be_accueil_concours
      expect(page).to have_link("vous inscrire")
      click_on("vous inscrire")
      expect(page).to be_inscription_concours
    end

  end #/contexte : un visiteur quelconque


  context 'un ancien concurrent' do
    before :all do
      @conc = TConcurrent.get_random(current: false, ancien: true)
    end
    let(:conc) { @conc }

    it 'trouve une page d’accueil conforme' do
      goto("concours")
      expect(page).to be_accueil_concours
      expect(page).to have_link("vous identifier")
    end

    it 'ne peut pas rejoindre la page des palmarès' do
      goto("concours/palmares")
      expect(page).not_to be_palmares_concours
      expect(page).to be_accueil_concours
    end

    it 'peut rejoindre son espace personnel' do
      goto("concours")
      expect(page).to have_link("vous identifier")
      click_on("vous identifier")
      expect(page).to be_identification_concours
      within("form#concours-login-form") do
        fill_in("p_mail", with: conc.mail)
        fill_in("p_concurrent_id", with: conc.id)
        click_on("S’identifier")
      end
      screenshot("ancien-after-identification")
      # Avant de rejoindre son espace personnel, il passe par la
      # demande d'inscription
      expect(page).to have_titre("Inscription au concours")
      expect(page).to have_link("rejoindre votre espace personnel")
      conc.click_on("rejoindre votre espace personnel")
      expect(page).to be_espace_personnel
    end

    it 'trouve un espace personnel conforme à la phase courante' do
      conc.rejoint_le_concours
      conc.click_on("rejoindre votre espace personnel")
      expect(page).to be_espace_personnel
      expect(page).to have_link("Se déconnecter")
      expect(page).to have_link("S’inscrire à la session")
      expect(page).to have_css("fieldset#concours-preferences")
      expect(page).to have_css("section#concours-historique")
      expect(page).to have_css("section#concours-destruction")
      expect(page).to have_content("En attendant le démarrage du prochain concours")
      # Les différences
      expect(page).not_to have_css("fieldset#concours-informations")
      expect(page).not_to have_link("TÉLÉCHARGER LA FICHE DE LECTURE")
      expect(page).not_to have_css("fieldset#concours-fichier-candidature")
      expect(page).not_to have_content("des informations sur le concours actuel")
    end

    it 'peut rejoindre ses fiches de lecture' do
      conc.rejoint_le_concours
      conc.click_on("rejoindre votre espace personnel")
      expect(page).to be_espace_personnel
      expect(page).to have_link(UI_TEXTS[:btn_vers_fiches_lecture])
      conc.click_on(UI_TEXTS[:btn_vers_fiches_lecture])
      expect(page).to be_fiches_lecture_concurrent
    end
  end

end
