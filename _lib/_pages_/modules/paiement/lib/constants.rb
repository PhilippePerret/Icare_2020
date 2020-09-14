# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour le paiement
=end

UI_TEXTS.merge!({
  button_download_iban: "Télécharger l’IBAN de Philippe Perret",
  button_signale_virement: 'lui signaler votre virement',
})

MESSAGES.merge!({
  objet_paiement: 'Objet : paiement du module d’apprentissage “%s”.',
  actu_real: '<span><strong>%{pseudo}</strong> devient un%{e} <em>vrai%{e}</em> icarien%{ne} !</span>',
  subject_mail_paiement_per_virement: 'Paiement par virement',
  notification_to_inform_phil_when_virement: "Une notification vous permettra d'informer Phil lorsque le virement aura été effectué.",
  annonce_new_notif_virement: "Une notification vous permet d'informer Phil que votre virement a été confirmé.",
  votre_facture: 'Votre facture', # titre du mail
  nouveau_paiement_icarien: 'Nouveau paiement'
})

ERRORS.merge!({
  express_checkout_failure: 'Un problème est malheureusement survenu (%{short} : %{long}).'
})
