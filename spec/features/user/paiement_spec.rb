# encoding: UTF-8
=begin
  Module de test du paiement
=end
feature "Paiement d'un module d'apprentissage" do


  scenario "un icarien peut payer par virement bancaire", only:true do
    pitch("Marion va rejoindre son bureau pour payer son module d'apprentissage.")
    degel('marion_envoie_deux_autres_documents_cycle_complet')
    # On modifie la date de paiement pour que la notification apparaisse.
    # Pour ce faire, on doit récupérer le watcher de paiement de Marion

    expect(marion).to have_watcher(wtype: 'paiement_module')
      "Marion devrait avoir un watcher de paiement."
    watcher_id = $watcher_id
    dwatcher_paiement = db_get('watchers', watcher_id)

    # On met la date à maintenant
    db_compose_update('watchers', watcher_id, {triggered_at: Time.now.to_i - 1})

    marion.rejoint_ses_notifications
    params = {unread:true, user_id:marion.id, wtype:'paiement_module'}
    expect(page).to have_notification(params),
      "La page des notifications devrait contenir la notification pour le paiement."

    pitch("Marion clique sur “Télécharger l'IBAN de Phil” pour payer par virement bancaire.")
    click_on("Télécharger l'IBAN de Phil")

    # Le premier watcher doit être détruit
    # TODO
  end
end
