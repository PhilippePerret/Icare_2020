# encoding: UTF-8
=begin
  Module de test du paiement
=end
# Pour les constantes
require './_lib/pages/modules/paiement/lib/constants'
require './_lib/_watchers_processus_/IcModule/annonce_virement/constants'
require './_lib/_watchers_processus_/_constants_'

feature "Paiement d'un module d'apprentissage" do

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
    degel('marion_avec_paiement')
    pitch("Marion va rejoindre son bureau pour payer son module d'apprentissage.")

    start_time = Time.now.to_i

    marion.rejoint_ses_notifications
    params = {unread:true, user_id:marion.id, wtype:'paiement_module'}
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

    # Le premier watcher doit être détruit
    expect(marion).not_to have_watcher(wtype: 'paiement_module'),
      "Marion ne devrait plus avoir de watcher de paiement."
    expect(marion).to have_watcher(wtype:'annonce_virement', after:start_time),
      "Marion devrait avoir le watcher d'annonce de virement"
    pitch("Le watcher de paiement de Marion a été remplacé par un watcher pour informer du virement.")

    # Un mail est envoyé à Marion pour l'informer de la procédure à suivre
    expect(marion).to have_mail(subject: MESSAGES[:subject_mail_paiement_per_virement], after:start_time)
    pitch("Marion reçoit un mail l'informant de la procédure à suivre.")

    # Marion se déconnecte
    logout

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
    expect(phil).to have_mail(subject:DATA_WATCHERS[:annonce_virement][:titre], after: start_time)
    # Marion reçoit un mail lui confirmant l'annonce de virement et la
    # remerciant
    expect(marion).to have_mail(subject:DATA_WATCHERS[:annonce_virement][:titre], after: start_time)
    pitch("Marion et Phil ont reçu un mail annonçant le virement.".freeze)

    # Le watcher d'annonce doit avoir été détruit
    expect(marion).not_to have_watcher(wtype:'annonce_virement', after:start_time)
    # Un nouveau watcher 'valide_paiement' doit avoir été instancié
    expect(marion).to have_watcher(wtype:'confirm_virement', after:start_time)
    pitch("Un nouveau watcher pour valider le paiement a été produit, et le précédent a été détruit.")
    logout

    # Je peux venir marquer le paiement effectué
    pitch("Après avoir vérifié que le virement avait bien été effectué, je reviens pour entériner le paiement.")
    phil.rejoint_ses_notifications

    # FAIRE LA SUITE
    # TODO

  end

  context 'un icarien m’ayant déjà mis en bénéficiaire' do
    scenario 'peut directement informer du virement', only:true do

      pitch("Marion, qui a déjà téléchargé mon IBAN, et m'a mis en bénéficiaire, veut simplement m'informer de son virement. Elle peut rejoindre son bureau pour le faire.")

      degel('marion_envoie_deux_autres_documents_cycle_complet')
      expect(marion).to have_watcher(wtype: 'paiement_module'),
        "Marion devrait avoir un watcher de paiement."
      watcher_id = $watcher_id
      dwatcher_paiement = db_get('watchers', watcher_id)
      db_compose_update('watchers', watcher_id, {triggered_at: Time.now.to_i - 1})

      # Pré-vérifiations
      expect(marion).not_to be_real,
        "Marion ne devrait pas être une *vraie* icarienne"

      # --- On peut procéder à l'opération

      start_time = Time.now.to_i

      marion.rejoint_ses_notifications
      params = {unread:true, user_id:marion.id, wtype:'paiement_module'}
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
      expect(phil).to have_mail(subject:DATA_WATCHERS[:annonce_virement][:titre], after: start_time),
        "Phil devrait avoir reçu un mail annonçant le virement."
      # Marion reçoit un mail lui confirmant l'annonce de virement et la
      # remerciant
      expect(marion).to have_mail(subject:DATA_WATCHERS[:annonce_virement][:titre], after: start_time),
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
      pitch("Marion devient une vraie icarien")
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
