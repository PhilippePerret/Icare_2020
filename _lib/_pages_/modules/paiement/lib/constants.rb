# encoding: UTF-8
=begin
  Constantes pour le paiement
=end

UI_TEXTS.merge!({
  button_download_iban: "Télécharger l’IBAN de Philippe Perret".freeze,
  button_signale_virement: 'lui signaler votre virement'.freeze,
})

MESSAGES.merge!({
  objet_paiement: 'Objet : paiement du module d’apprentissage “%s”.'.freeze,
  actu_real: '<span><strong>%{pseudo}</strong> devient un%{e} <em>vrai%{e}</em> icarien%{ne} !</span>'.freeze,
  subject_mail_paiement_per_virement: 'Paiement par virement'.freeze,
  notification_to_inform_phil_when_virement: "Une notification vous permettra d'informer Phil lorsque le virement aura été effectué.".freeze,
  annonce_new_notif_virement: "Une notification vous permet d'informer Phil que votre virement a été confirmé.".freeze,
  votre_facture: 'Votre facture'.freeze, # titre du mail
})

ERRORS.merge!({
  express_checkout_failure: 'Un problème est malheureusement survenu (%{short} : %{long}).'.freeze
})
