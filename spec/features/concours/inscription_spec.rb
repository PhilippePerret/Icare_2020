# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de test de la section concours, partie inscription
=end
feature "Section d'inscription de la partie concours" do
  before(:all) do
    require './_lib/_pages_/concours/xrequired/constants'
  end


  scenario "Une page conforme permet de s'inscrire une première fois au concours", only:true do
    goto("concours/inscription")
    expect(page).to have_titre(UI_TEXTS[:titre_page_inscription])
    # La page est composée de deux parties :
    #   1) quand l'user est déjà inscrit
    #   2) pour une première inscription

    start_time = Time.now.to_i

    # La page contient les bons éléments
    expect(page).to have_css("fieldset#user-signedup")
    expect(page).to have_css("fieldset#signup-section")
    expect(page).to have_css("form#concours-signedup-form")
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
    dc = db_exec("SELECT * FROM #{DBTABLE_CONCURRENTS} WHERE patronyme = ?", [pseudo_concurrent]).first
    expect(dc).not_to eq(nil),
      "Les informations du concurrent auraient dû être enregistrées dans la base"
    concurrent_id = dc[:concurrent_id]
    expect(dc[:mail]).to eq(concurrent_mail)
    expect(dc[:sexe]).to eq("F")

    # Les données sont justes, dans la table des concours
    dcc = db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE user_id = ? and annee = ?", [concurrent_id, ANNEE_CONCOURS_COURANTE]).first
    expect(dcc).not_to eq(nil),
      "La donnée aurait dû être enregistrée dans la base de données"
    expect(dcc[:fiche_required]).to eq(1)

    # Le participant doit avoir reçu un mail lui confirmant son inscription
    # au concours
    expect(TMails).to be_exists(concurrent_mail, {after:start_time, subject: MESSAGES[:concours_signed_confirmation]}),
      "Le concurrent devrait avoir reçu un mail confirmant son inscription"

    # Participant doit avoir reçu un mail pour confirmer son adresse mail
    # Non, pour le moment, il faut qu'il fasse attention.

    # Une actualité doit annoncer la nouvelle inscription
    data_actu = {only_one: true, type: "CONCOURS", after: start_time}
    expect(TActualites.exists?(data_actu)).to be(true),
      "Une actualité devrait annoncer l'inscription du concurrent"

    # La page doit contenir les bons éléments
    # - Les trois sections principales
    expect(page).to have_css("section#concours-informations"),
      "La page devrait contenir la section des informations sur le concours"
    expect(page).to have_css("fieldset#concours-envoi-dossier"),
      "La page devrait contenir la section permettant d'envoyer le dossier"
    expect(page).to have_css("section#concours-historique"),
      "La page devrait contenir l'historique de concours du concurrent"
    # - le formulaire pour transmettre le fichiere
    expect(page).to have_css("form#concours-dossier-form"),
      "La page devrait présenter le formulaire d'envoi du dossier"
    within("form#concours-dossier-form") do
      expect(page).to have_button(UI_TEXTS[:concours_bouton_send_dossier])
    end

  end

  context 'un concurrent faisant plein d’erreurs d’inscription' do
    scenario 'ne parvient pas à s’inscrire' do
      implementer(__FILE__,__LINE__)
    end
  end #/context concurrent avec beaucoup d'erreurs

  context 'un visiteur quelconque' do
    scenario 'qui ne demande pas de fiche de lecture' do
      implemente(__FILE__,__LINE__)
      # Est bien marqué dans la base de données
      # TODO
    end
  end


  context 'un visiteur déjà inscrit' do
    scenario 'ne peut pas se réinscrire au concours' do
      implementer(__FILE__,__LINE__)
    end
  end





  context 'un icarien identifié' do
    scenario 'peut s’inscrire très facilement au concours' do
      implementer(__FILE__,__LINE__)
    end
  end




end
