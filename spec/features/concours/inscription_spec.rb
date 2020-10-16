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

    # La page contient les bons éléments
    expect(page).to have_css("fieldset#user-signedup")
    expect(page).to have_css("fieldset#signup-section")
    expect(page).to have_css("form#concours-signedup-form")
    expect(page).to have_css("form#concours-signup-form")

    # Un utilisateur s'inscrit
    within("form#concours-signup-form") do
      fill_in("p_patronyme", with: "Participant #{Time.now.to_i}")
      fill_in("p_mail", with: "participant@philippeperret.fr")
      fill_in("p_mail_confirmation", with: "participant@philippeperret.fr")
      select("homme", in: "sexe")
      check("p_reglement")
      check("p_fiche_lecture")
      click_on(UI_TEXTS[:concours_bouton_signup])
    end
    sleep 10
    expect(page).to have_titre(UI_TEXTS[:concours_titre_participant])

    # Les données sont justes, dans la table des concurrents
    # TODO

    # Les données sont justes, dans la table des concours
    # TODO

    # Le participant doit avoir reçu un mail lui confirmant son inscriptino
    # au concours
    # TODO

    # Participant doit avoir reçu un mail pour confirmer son adresse mail
    # TODO

    # Une actualité doit annoncer la nouvelle inscription
    # TODO

    # La page doit contenir le bon message en fonction du fait que le
    # concurrent a donné son dossier ou non.
    # TODO

  end


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
