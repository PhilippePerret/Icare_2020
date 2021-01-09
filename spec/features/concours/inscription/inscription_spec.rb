# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de la section concours, partie inscription
=end
require_relative './_required'

feature "Section d'inscription de la partie concours" do
  before(:all) do
    headless
    degel("concours-phase-1")
    require './_lib/_pages_/concours/inscription/constants'
  end

  def proceed_inscription_with(data)
    goto("concours/inscription")
    start_time = Time.now.to_i
    # Un utilisateur s'inscrit
    data[:patronyme] ||= "Concurrent #{start_time + rand(10000)}"
    data[:mail]   ||= "#{data[:patronyme].downcase.gsub(/ /,'')}@philippeperret.fr"
    data[:mail_confirmation ] ||= data[:mail]
    data[:sexe] ||= "féminin"
    within("form#concours-signup-form") do
      fill_in("p_patronyme", with: data[:patronyme])
      fill_in("p_mail", with: data[:mail])
      fill_in("p_mail_confirmation", with: data[:mail_confirmation])
      select(data[:sexe], from: "p_sexe")
      if data[:reglement] === false
        uncheck("p_reglement")
      else
        check("p_reglement")
      end
      if data[:fiche_lecture] === false
        uncheck("p_fiche_lecture")
      else
        check("p_fiche_lecture")
      end
      # On soumet le formulaire
      click_on(UI_TEXTS[:concours_bouton_signup])
    end
  end #/ proceed_inscription_with

  context 'un candidat avec une adresse existante' do
    scenario 'est renvoyé à l’identification' do
      dc = db_exec("SELECT mail FROM #{DBTBL_CONCURRENTS} LIMIT 1").first
      proceed_inscription_with(mail: dc[:mail])
      expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_titre("Identification")
      expect(page).to have_message("Vous êtes déjà concurrent du concours")
    end
  end

  context 'un candidat avec une adresse mail invalide ou existante' do
    scenario 'ne parvient pas à s’inscrire' do
      proceed_inscription_with(mail: "#{'xy'*150}@chez.lui")
      expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
      expect(page).to have_content("Le formulaire est invalide")
      proceed_inscription_with(mail: "mauvais@mail")
      expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
      expect(page).to have_content("Le formulaire est invalide")
    end
  end

  context 'un candidat avec un mauvais patronyme' do
    scenario 'ne parvient pas à s’inscrire' do
      dc = db_exec("SELECT patronyme FROM #{DBTBL_CONCURRENTS} LIMIT 1").first
      proceed_inscription_with(patronyme: dc[:patronyme])
      expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
      expect(page).to have_erreur(ERRORS[:concours_patronyme_exists])
      proceed_inscription_with(patronyme: "x"*257)
      expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
      expect(page).to have_content("Le formulaire est invalide")
    end
  end

  context 'un concurrent avec une mauvaise confirmation' do
    scenario 'ne peut pas s’inscrire' do
      proceed_inscription_with(mail_confirmation: "mauvaise@confirmation")
      expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
      expect(page).to have_content("Le formulaire est invalide")
    end
  end


  context 'un inscrit qui ne demande pas de fiche de lecture' do
    scenario 'n’en recevra pas (d’après ses options)' do
      start_time = Time.now.to_i
      goto("concours/inscription")
      # Un utilisateur s'inscrit
      pseudo_concurrent = "Concurrent #{Time.now.to_i + rand(10000)}"
      concurrent_mail   = "#{pseudo_concurrent.downcase.gsub(/ /,'')}@philippeperret.fr"
      within("form#concours-signup-form") do
        fill_in("p_patronyme", with: pseudo_concurrent)
        fill_in("p_mail", with: concurrent_mail)
        fill_in("p_mail_confirmation", with: concurrent_mail)
        select("féminin", from: "p_sexe")
        check("p_reglement")
        uncheck("p_fiche_lecture")
        click_on(UI_TEXTS[:concours_bouton_signup])
      end

      dc = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE mail = ?", [concurrent_mail]).first
      expect(dc).not_to eq(nil)
      expect(dc[:options][1]).to eq("0")
    end
  end

  context 'un icarien identifié' do
    scenario 'peut s’inscrire au concours en cliquant sur un simple bouton', gel:true do
      # NOTE : produit le gel 'marion-concurrente-concours'
      marion.rejoint_le_site
      goto("concours/accueil")
      marion.click_on(UI_TEXTS[:concours_bouton_inscription])
      expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
      expect(page).not_to have_css("form#concours-signup-form")
      expect(page).to have_link("S’inscrire au concours de synopsis")
      marion.click_on("S’inscrire au concours de synopsis")
      expect(page).to have_titre(UI_TEXTS[:concours_titre_participant])
      # *** Vérifications dans les tables ***
      dc = db_exec("SELECT concurrent_id, patronyme FROM #{DBTBL_CONCURRENTS} WHERE mail = ?", [marion.mail]).first
      expect(dc).not_to eq(nil)
      expect(dc[:patronyme]).to eq(marion.patronyme || marion.pseudo)
      dcc = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} where annee = ? AND concurrent_id = ?", [ANNEE_CONCOURS_COURANTE, dc[:concurrent_id]]).first
      expect(dcc).not_to eq(nil)

      gel('marion-concurrente-concours', <<-TEXT)
      Gel qui permet d'avoir une icarienne, Marion, qui s'est inscrite au concours de synopsis
      organisé tous les ans par l'atelier Icare.
      TEXT
      pitch("Production du gel 'marion-concurrente-concours'")
    end
  end

end
