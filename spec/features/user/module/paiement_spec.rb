# encoding: UTF-8
=begin
  Module de test du paiement
=end
# Pour les constantes
require_relative './_required'

feature "Paiement d'un module d'apprentissage avec les différents modes de paiement" do
  before(:all) do
    require "#{FOLD_REL_PAGES}/modules/paiement/lib/constants"
    require './_lib/_watchers_processus_/IcModule/annonce_virement/constants'
    require './_lib/_watchers_processus_/_constants_'
  end

  it 'doit être fait à la main', seul:true do
    manip = "-- Dégeler 'marion_avec_paiement' (icare degel marion_avec_paiement)\n-- S'identifier comme Marion (gmail)\n-- Procéder au paiement avec le compte sandbox de Benoit"
    puts manip.rouge
    expect(4).to eq(5), "Le vrai test du paiement doit être fait à la main : \n#{manip}"
  end

  scenario 'juste pour produire le gel marion_avec_paiement', gel:true do
    # On modifie la date de paiement pour que la notification apparaisse.
    # Pour ce faire, on doit récupérer le watcher de paiement de Marion
    degel('marion_envoie_deux_autres_documents_cycle_complet')
    expect(marion).to have_watcher(wtype: 'paiement_module'),
      "Marion devrait avoir un watcher de paiement."
    watcher_id = $watcher_id
    dwatcher_paiement = db_get('watchers', watcher_id)
    db_compose_update('watchers', watcher_id, {triggered_at: Time.now.to_i - 1})
    gel('marion_avec_paiement', <<-DEF)
Ce gel part du gel marion_envoie_deux_autres_documents_cycle_complet (mais il pourrait partir d'autre part) et il modifie la date de paiement de Marion, dans son watcher, pour qu'elle ait un paiement à effectuer.
Noter cependant qu'en utilisant ce gel, s'il n'a pas été actualisé, il va provoquer une erreur de non paiement au bout d'un certain temps.
Pour être actualiser, on doit jouer le premier cas du fichier :
#{__FILE__}
vers la ligne #{__LINE__}

On peut aussi le jouer en cherchant les tags `gel` (`-t gel`)
    DEF
  end










  scenario "un icarien peut payer par virement bancaire" do

    headless(true) # pour voir ce qui se passe
    use_profile_downloader(true)

    # Pour les titres de mails, notamment
    require './_lib/_watchers_processus_/IcModule/annonce_virement/constants'

    degel('marion_avec_paiement')
    pitch("Marion va rejoindre son bureau pour payer son module d'apprentissage.")

    start_time = Time.now.to_i

    marion.rejoint_ses_notifications
    # sleep 20
    params = {major:true, user_id:marion.id, wtype:'paiement_module'}
    expect(page).to have_notification(params),
      "La page des notifications devrait contenir la notification pour le paiement."
    expect(page).to have_link('procéder au paiement')

    pitch("Marion clique sur “procéder au paiement” pour rejoindre la section des paiements.")
    click_on('procéder au paiement')
    screenshot('marion-procede-paiement')

    expect(page).to have_titre('Paiement')
    expect(page).to have_link(UI_TEXTS[:button_download_iban]),
      "La page devrait contenir un lien pour charger mon IBAN"

    start_time = Time.now.to_i

    pitch("Marion clique sur “#{UI_TEXTS[:button_download_iban]}” pour payer par virement bancaire.")
    click_on(UI_TEXTS[:button_download_iban])
    screenshot('marion-download-iban')
    sleep 1.5
    # Le premier watcher doit être détruit
    expect(marion).not_to have_watcher(wtype: 'paiement_module'),
      "Marion ne devrait plus avoir de watcher de paiement."
    expect(marion).to have_watcher(wtype:'annonce_virement', after: start_time),
      "Marion devrait avoir le watcher d'annonce de virement"
    pitch("Le watcher de paiement de Marion a été remplacé par un watcher pour informer du virement.")

    # Marion se déconnecte
    logout

    # Un mail est envoyé à Marion pour l'informer de la procédure à suivre
    expect(marion).to have_mail(subject: MESSAGES[:subject_mail_paiement_per_virement], after:start_time)
    pitch("Marion reçoit un mail l'informant de la procédure à suivre.")

    pitch("Phil va venir sur son bureau et trouver la nouvelle notification pour annonce de paiement de Marion.")
    phil.rejoint_ses_notifications
    screenshot('phil-annonce-virement')
    expect(page).to have_notification(user:marion, wtype:'annonce_virement'),
      "Je devrais trouver la notification d'annonce de viremenet"
    # Phil se déconnecte
    logout

    pitch("Marion revient plus tard pour valider le paiement")
    marion.rejoint_ses_notifications
    expect(page).to have_notification(wtype:'annonce_virement'),
      "Marion devrait trouver une notification d'annonce de virement"

    pitch("Elle trouve une notification pour annoncer le virement et clique sur le bouton.")
    click_on(UI_TEXTS[:button_confirm_virement])

    # Phil reçoit un mail pour l'avertir
    pitch("Un mail m'est envoyé pour m'annoncer le virement")
    expect(phil).to have_mail(subject:MESSAGES[:titre_mail_admin], after: start_time, message:"vient de procéder au paiement par virement")

    # Marion reçoit un mail lui confirmant l'annonce de virement et la
    # remerciant
    pitch("Un mail est envoyé à Marion pour lui annoncer le virement.")
    expect(marion).to have_mail(subject:MESSAGES[:titre_mail_icarien], after: start_time, message:"Vous venez de confirmer le paiement de votre module")

    # Le watcher d'annonce doit avoir été détruit
    expect(marion).not_to have_watcher(wtype:'annonce_virement', after:start_time)
    # Un nouveau watcher 'valide_paiement' doit avoir été instancié
    expect(marion).to have_watcher(wtype:'confirm_virement', after:start_time)
    pitch("Un nouveau watcher pour valider le paiement a été produit, et le précédent a été détruit.")
    wch_conf_paie_id = $watcher_id
    logout

    # Je peux venir marquer le paiement effectué
    pitch("Après avoir vérifié que le virement avait bien été effectué sur mon compte bancaire, je reviens pour entériner le paiement. Cela transformera Marion en vraie icarienne, ce qui sera annoncé dans les actualités.")
    phil.rejoint_ses_notifications

    screenshot('notifs-phil-apres-marion-confirm-paiement')
    expect(page).to have_notification(wch_conf_paie_id)

    # === Je procède à la validation ===
    within("div#watcher-#{wch_conf_paie_id}") do
      click_on('Confirmer le paiement'.freeze)
    end
    screenshot('phil-confirm-virement-marion')
    expect(page).to have_message("Le paiement a bien été confirmé.")

    marion.reset

    # Le module est marqué payé
    record_paiement = db_get('paiements', {icmodule_id: marion.icmodule_id})
    expect(record_paiement).not_to be(nil),
      "Un nouvel enregistrement de paiement, pour le module, devrait avoir été enregistré."
    pitch("Le module a bien été marqué payé (un nouveau paiement a été effectué pour lui)")
    # Marion a reçu un mail de confirmation
    expect(marion).to have_mail(after: start_time, subject:MESSAGES[:votre_facture]),
      "MarionM devrait avoir reçu un mail avec sa facture"
    pitch("Marion a reçu un mail avec sa facture")
    # Marion devient une vrai icarienne
    expect(marion).to be_real
    pitch("Marion devient une vraie icarienne")
    # Une actualité annonce que Marion est devenue une vraie icarienne
    expect(TActualites).to have_actualite(user_id: marion.id, type:'REALICARIEN', after: start_time)
    pitch("Une actualité annonce que Marion est devenue une vraie icarienne.")
    # Pas d'autre paiement
    expect(marion).not_to have_watcher(wtype: 'paiement_module'),
      "Marion ne devrait plus avoir de matcher de paiement"
    pitch("Comme le module n'est pas à durée indéterminée, il n'est pas à repayer, pas de nouveau matcher de paiement")

    logout

  end









  context 'Un icarien avec un module de suivi de projet' do

    scenario 'juste pour produire le gel avec un paiement', gel: true do
      degel('elie_demarre_son_module')
      expect(elie).to have_watcher(wtype:'paiement_module'),
        "Élie devrait avoir un watcher de paiement pour son module."
      watcher_id_init = $watcher_id
      dwatcher_paiement = db_get('watchers', watcher_id_init)
      db_compose_update('watchers', watcher_id_init, {triggered_at: Time.now.to_i - 1})
      gel('elie-avec-paiement', <<-TXT)
      Dans ce gel, élie doit payer son module d'apprentissage (suivi de projet).
      TXT
    end

    scenario 'ne peut pas simuler le paiement en appelant op=ok' do
      pitch("Élie, qui suit le module de suivi de projet intensif vient payer son module, ce qui lui affecte une nouvelle date d'échéance de paiement.")

      degel('elie-avec-paiement')

      start_time = Time.now.to_i

      # *** opérations préliminaires ***

      # Il faut régler le watcher de telle sorte que la notification de paiement
      # sera visible par Élie.
      expect(elie).to have_watcher(wtype:'paiement_module'),
        "Élie devrait avoir un watcher de paiement pour son module."

      elie.rejoint_ses_notifications
      params = {major:true, user_id:elie.id, wtype:'paiement_module'}
      expect(page).to have_notification(params),
        "La page des notifications devrait contenir la notification pour le paiement."
      expect(page).to have_link('procéder au paiement')

      pitch("Élie clique sur “procéder au paiement” pour rejoindre la section des paiements et clique sur le bouton Paypal.")
      elie.click_on('procéder au paiement')

      goto('modules/paiement?op=ok')
      screenshot("direct-on-paiement")

      expect(db_get('paiements', {user_id: elie.id, icmodule_id:elie.icmodule_id})).to eq(nil),
        "Elie ne devrait pas avoir de premier paiement pour le module"

    end

    # Test à faire manuellement :
    # scenario 'peut payer son module et avoir une nouvelle date d’échéance de paiement' do
    #
    #   degel('elie-avec-paiement')
    #
    #   pitch("Élie, qui suit le module de suivi de projet intensif vient payer son module, ce qui lui affecte une nouvelle date d'échéance de paiement.")
    #
    #   start_time = Time.now.to_i
    #
    #   # *** opérations préliminaires ***
    #
    #   elie.rejoint_ses_notifications
    #   params = {major:true, user_id:elie.id, wtype:'paiement_module'}
    #   expect(page).to have_notification(params),
    #     "La page des notifications devrait contenir la notification pour le paiement."
    #   expect(page).to have_link('procéder au paiement')
    #
    #   pitch("Élie clique sur “procéder au paiement” pour rejoindre la section des paiements et clique sur le bouton Paypal.")
    #
    #   # Par le vrai formulaire
    #   click_on('procéder au paiement')
    #   screenshot('elie-procede-paiement')
    #   expect(page).to have_titre('Paiement')
    #
    #   # Pour simuler le clic sur le bouton de paiement
    #   paypal_window =
    #     window_opened_by do
    #       within_frame(find(".paypal-buttons iframe")) do
    #         first(".paypal-button").click
    #       end
    #     end
    #
    #   # Pour les données secrètes de Benoit (qui paie)
    #   require './_lib/data/secret/benoit' # => BENOIT
    #   within_window(paypal_window) do
    #     # similar, just couple of extra steps and calling reusable method for details
    #     Capybara.using_wait_time(5) do
    #       # accept cookies
    #       click_button("Accepter les cookies") if page.has_button?("Accepter les cookies")
    #
    #       # switch to login form (if needed)
    #       click_on("Log In") if page.has_content?("PayPal Guest Checkout")
    #
    #       fill_in "login_email", with: BENOIT[:mail] # c'est Benoit qui paie
    #       click_on "Suivant"
    #       fill_in "login_password", with: BENOIT[:password] # cf. ci-dessus
    #       find("#btnLogin").click
    #       click_on("Payer")
    #     end
    #   end # / fin de travail dans la fenêtre de paypal
    #   sleep 2
    #   screenshot("after-paiement-elie")
    #   sleep 4
    #
    #   expect(db_get('paiements', {user_id: elie.id, icmodule_id:elie.icmodule_id})).not_to eq(nil),
    #     "Il devrait y avoir un premier paiement pour le module"
    #   expect(db_get('watchers', watcher_id_init)).to eq(nil),
    #     "Le watcher de paiement d'Élie devrait avoir été supprimé"
    #   new_watcher_paiement = db_get('watchers', {wtype:'paiement_module', objet_id: elie.icmodule_id})
    #   expect(new_watcher_paiement).not_to eq(nil),
    #     "Le nouveau watcher paiement pour le module d'Élie (##{elie.icmodule_id}) devrait avoir été créé"
    #   pitch("Le watcher de paiement initial a été supprimé et remplacé par un nouveau")
    #   expect(new_watcher_paiement[:triggered_at]).to be > (Time.now.to_i + 29.days)
    #   pitch("Le nouveau watcher de paiement possède un bon trigger")
    #   expect(elie).to have_mail(after: start_time, subject:MESSAGES[:votre_facture])
    #   pitch("Élie a reçu un mail de confirmation avec sa facture")
    #   expect(phil).to have_mail(after: start_time, subject:MESSAGES[:nouveau_paiement_icarien], message:"un paiement vient d’être effectué")
    #   pitch("J'ai reçu un mail m'annonçant le paiement")
    #
    #   logout
    #
    # end
  end




  context 'un icarien m’ayant déjà mis en bénéficiaire' do

    scenario 'peut directement informer du virement' do

      pitch("Marion, qui a déjà téléchargé mon IBAN, et m'a mis en bénéficiaire, veut simplement m'informer de son virement. Elle peut rejoindre son bureau pour le faire.")

      degel('marion_envoie_deux_autres_documents_cycle_complet')

      expect(marion).to have_watcher(wtype: 'paiement_module'),
        "Marion devrait avoir un watcher de paiement."
      watcher_id = $watcher_id
      dwatcher_paiement = db_get('watchers', watcher_id)
      db_compose_update('watchers', watcher_id, {triggered_at: Time.now.to_i - 1})

      # Pré-vérifiations
      expect(marion).not_to be_real,
        "Marion ne devrait pas être une *vraie* icarienne (son bit 24 vaut #{marion.options[24]})"

      # --- On peut procéder à l'opération

      start_time = Time.now.to_i

      marion.rejoint_ses_notifications
      params = {major:true, user_id:marion.id, wtype:'paiement_module'}
      expect(page).to have_notification(params),
        "La page des notifications devrait contenir la notification pour le paiement."
      expect(page).to have_link('procéder au paiement')

      pitch("Marion clique sur “procéder au paiement” pour rejoindre la section des paiements.")
      click_on('procéder au paiement')
      screenshot('marion-procede-paiement')

      expect(page).to have_titre('Paiement')

      start_time = Time.now.to_i

      expect(page).to have_link(UI_TEXTS[:button_signale_virement]),
        "La page devrait contenir un lien pour informer du virement"
      click_on(UI_TEXTS[:button_signale_virement])

      marion.reset

      pitch("Marion se retrouve sur la page des notifications.")
      expect(page).to have_titre('Notifications')

      # Le premier watcher doit être détruit
      expect(marion).not_to have_watcher(wtype: 'paiement_module'),
        "Marion ne devrait plus avoir de watcher de paiement."
      expect(marion).to have_watcher(wtype:'annonce_virement', after: start_time),
        "Marion devrait avoir le watcher d'annonce de virement"
      pitch("Le watcher de paiement de Marion a été remplacé par un watcher pour informer du virement.")

      # Un mail est envoyé à Marion pour l'informer de la procédure à suivre
      expect(marion).not_to have_mail(subject: MESSAGES[:subject_mail_paiement_per_virement], after:start_time)
      pitch("Marion ne reçoit pas le mail l'informant de la procédure à suivre, puisqu'elle la connait déjà et qu'elle est conduite au bon endroit.")

      pitch("Elle trouve sur son bureau une notification pour annoncer le virement et clique sur le bouton.")
      click_on(UI_TEXTS[:button_confirm_virement])

      # Phil reçoit un mail pour l'avertir
      expect(phil).to have_mail(subject:subject_of_mail('_watchers_processus_/IcModule/annonce_virement/mail_admin.erb'), after: start_time),
        "Phil devrait avoir reçu un mail annonçant le virement."
      # Marion reçoit un mail lui confirmant l'annonce de virement et la
      # remerciant
      expect(marion).to have_mail(subject:subject_of_mail('_watchers_processus_/IcModule/annonce_virement/mail_user.erb'), after: start_time),
        "Marion devrait avoir reçu un mail confirmant l'annonce du virement."
      pitch("Marion et Phil ont reçu un mail annonçant le virement.".freeze)

      # Le watcher d'annonce doit avoir été détruit
      expect(marion).not_to have_watcher(wtype:'annonce_virement', after:start_time)
      # Un nouveau watcher 'valide_paiement' doit avoir été instancié
      expect(marion).to have_watcher(wtype:'confirm_virement', after:start_time)
      wch_conf_paie_id = $watcher_id
      pitch("Un nouveau watcher pour valider le paiement a été produit, et le précédent a été détruit.")
      logout

      # Je peux venir marquer le paiement effectué
      pitch("Après avoir vérifié que le virement avait bien été effectué, je reviens pour entériner le paiement.")
      phil.rejoint_ses_notifications
      screenshot('notifs-phil-apres-marion-confirm-paiement')
      expect(page).to have_notification(wch_conf_paie_id)

      # === Je procède à la validation ===
      within("div#watcher-#{wch_conf_paie_id}") do
        click_on('Confirmer le paiement'.freeze)
      end
      screenshot('phil-confirm-virement-marion')

      marion.reset

      # Le module est marqué payé
      record_paiement = db_get('paiements', {icmodule_id: marion.icmodule_id})
      expect(record_paiement).not_to be(nil),
        "Un nouvel enregistrement de paiement, pour le module, devrait avoir été enregistré."
      pitch("Le module a bien été marqué payé (un nouveau paiement a été effectué pour lui)")
      # Marion a reçu un mail de confirmation
      expect(marion).to have_mail(after: start_time, subject:MESSAGES[:votre_facture])
      pitch("Marion a reçu un mail avec sa facture")
      # Marion devient une vrai icarienne
      expect(marion).to be_real
      pitch("Marion devient une vraie icarienne")
      # Une actualité annonce que Marion est devenue une vraie icarienne
      expect(TActualites).to have_actualite(user_id: marion.id, type:'REALICARIEN', after: start_time)
      pitch("Une actualité annonce que Marion est devenue une vraie icarienne.")
      # Pas d'autre paiement
      expect(marion).not_to have_watcher(wtype: 'paiement_module'),
        "Marion ne devrait plus avoir de matcher de paiement"
      pitch("Comme le module n'est pas à durée indéterminée, il n'est pas à repayer, pas de nouveau matcher de paiement")
    end
  end
end
