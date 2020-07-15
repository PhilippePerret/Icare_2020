# encoding: UTF-8
=begin
  Module de test du paiement
=end
require './_lib/pages/modules/paiement/lib/constants'
feature "Paiement d'un module d'apprentissage" do


  scenario "un icarien peut payer par virement bancaire", only:true do
    pitch("Marion va rejoindre son bureau pour payer son module d'apprentissage.")
    degel('marion_envoie_deux_autres_documents_cycle_complet')
    # On modifie la date de paiement pour que la notification apparaisse.
    # Pour ce faire, on doit récupérer le watcher de paiement de Marion

    start_time = Time.now.to_i

    expect(marion).to have_watcher(wtype: 'paiement_module'),
      "Marion devrait avoir un watcher de paiement."
    watcher_id = $watcher_id
    dwatcher_paiement = db_get('watchers', watcher_id)

    # On met la date à maintenant
    db_compose_update('watchers', watcher_id, {triggered_at: Time.now.to_i - 1})

    marion.rejoint_ses_notifications
    params = {unread:true, user_id:marion.id, wtype:'paiement_module'}
    expect(page).to have_notification(params),
      "La page des notifications devrait contenir la notification pour le paiement."
    expect(page).to have_link('procéder au paiement')

    pitch("Marion clique sur “procéder au paiement” pour rejoindre la section des paiements.")
    click_on('procéder au paiement')

    expect(page).to have_titre('Paiement')
    expect(page).to have_link(UI_TEXTS[:button_download_iban]),
      "La page devrait contenir un lien pour charger mon IBAN"

    pitch("Marion clique sur “#{UI_TEXTS[:button_download_iban]}” pour payer par virement bancaire.")
    click_on(UI_TEXTS[:button_download_iban])

    # Le premier watcher doit être détruit
    expect(marion).not_to have_watcher(wtype: 'paiement_module'),
      "Marion ne devrait plus avoir de watcher de paiement."
    expect(marion).to have_watcher(wtype:'annonce_virement', after:start_time)
    pitch("Le watcher de paiement de Marion a été remplacé par un watcher pour informer du virement.")

    logout

    pitch("Phil va venir sur son bureau et trouver la nouvelle notification pour annonce de paiement de Marion.")
    phil.rejoint_ses_notifications
    screenshot('phil-annonce-virement')
    expect(page).to have_notification(user:marion, wtype:'annonce_virement'),
      "Je devrais trouver la notification d'annonce de viremenet"


  end
end
