# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de la section concours, partie inscription
=end
feature "Section d'inscription de la partie concours" do
  before(:all) do
    degel("benoit_frigote_phil_marion_et_elie")
    require_support('concours')
    require './_lib/_pages_/concours/inscription/constants' # propres à l'inscription
    TConcours.reset
    TConcours.peuple
  end


  scenario "Une page conforme permet de s'inscrire une première fois au concours" do
    goto("concours/inscription")
    expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])

    start_time = Time.now.to_i

    # La page contient les bons éléments
    expect(page).to have_css("fieldset#signup-section")
    expect(page).to have_css("form#concours-signup-form")

    # Un utilisateur s'inscrit
    pseudo_concurrent = "Concurrent #{Time.now.to_i}"
    concurrent_mail   = "#{pseudo_concurrent.downcase.gsub(/ /,'')}@philippeperret.fr"
    within("form#concours-signup-form") do
      fill_in("p_patronyme", with: pseudo_concurrent)
      fill_in("p_mail", with: concurrent_mail)
      fill_in("p_mail_confirmation", with: concurrent_mail)
      select("féminin", from: "p_sexe")
      check("p_reglement")
      check("p_fiche_lecture")
      click_on(UI_TEXTS[:concours_bouton_signup])
    end
    screenshot("soumission-signup-concours")
    expect(page).to have_titre(UI_TEXTS[:concours_titre_participant])

    # Les données sont justes, dans la table des concurrents
    dc = db_exec("SELECT * FROM #{DBTBL_CONCURRENTS} WHERE patronyme = ?", [pseudo_concurrent]).first
    expect(dc).not_to eq(nil),
      "Les informations du concurrent auraient dû être enregistrées dans la base"
    concurrent_id = dc[:concurrent_id]
    expect(dc[:mail]).to eq(concurrent_mail)
    expect(dc[:sexe]).to eq("F")
    expect(dc[:options][0]).to eq("1")
    expect(dc[:options][1]).to eq("1") # fiche de lecture

    # Les données sont justes, dans la table des concours
    dcc = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ? and annee = ?", [concurrent_id, ANNEE_CONCOURS_COURANTE]).first
    expect(dcc).not_to eq(nil),
      "La donnée aurait dû être enregistrée dans la base de données"

    # Le participant doit avoir reçu un mail lui confirmant son inscription
    # au concours
    expect(TMails).to be_exists(concurrent_mail, {after:start_time, subject: MESSAGES[:concours_signed_confirmation]}),
      "Le concurrent devrait avoir reçu un mail confirmant son inscription"

    # Un mail doit avoir été envoyé à l'administration
    expect(phil).to have_mail(after: start_time, subject: MESSAGES[:concours_new_signup_titre])

    # Une actualité doit annoncer la nouvelle inscription
    data_actu = {only_one: true, type: "CONCOURS", after: start_time}
    expect(TActualites.exists?(data_actu)).to be(true),
      "Une actualité devrait annoncer l'inscription du concurrent"

    # La page doit contenir les bons éléments
    # - Les trois sections principales
    expect(page).to have_css("fieldset#concours-informations"),
      "La page devrait contenir la section des informations sur le concours"
    expect(page).to have_css("fieldset#concours-preferences"),
      "La page devrait contenir une partie pour ses préférences…"
    expect(page).to have_css("fieldset#concours-envoi-dossier"),
      "La page devrait contenir la section permettant d'envoyer le dossier"
    expect(page).to have_css("section#concours-historique"),
      "La page devrait contenir l'historique de concours du concurrent"
    expect(page).to have_css("section#concours-destruction"),
      "la page devrait contenir une partie pour détruire son inscription"
    # - le formulaire pour transmettre le fichiere
    expect(page).to have_css("form#concours-dossier-form"),
      "La page devrait présenter le formulaire d'envoi du dossier"
    within("form#concours-dossier-form") do
      expect(page).to have_button(UI_TEXTS[:concours_bouton_send_dossier])
    end

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

  context 'un candidat avec une adresse mail invalide ou existante' do
    scenario 'ne parvient pas à s’inscrire' do
      dc = db_exec("SELECT mail FROM #{DBTBL_CONCURRENTS} LIMIT 1").first
      proceed_inscription_with(mail: dc[:mail])
      expect(page).not_to have_titre(UI_TEXTS[:concours_titre_participant])
      expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
      expect(page).to have_erreur(ERRORS[:concours_mail_exists])
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
    scenario 'peut s’inscrire au concours en cliquant sur un simple bouton', only:true do
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
    end
  end

end
