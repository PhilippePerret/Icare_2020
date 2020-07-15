# encoding: UTF-8
=begin
  Module de test du paiement
=end
# Pour les constantes
require './_lib/pages/modules/paiement/lib/constants'
require './_lib/_watchers_processus_/IcModule/annonce_virement/constants'
require './_lib/_watchers_processus_/_constants_'

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

  end

  context 'avec un icarien m’ayant déjà mis en bénéficiaire' do
    scenario 'il peut directement informer du virement' do
      pending "à implémenter"
    end
  end
end
