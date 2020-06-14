# encoding: UTF-8
=begin
  Constantes pour le paiement
=end

MESSAGES.merge!({
  objet_paiement: 'Objet : paiement du module d’apprentissage “%s”.'.freeze,
  actu_real: '<span><strong>%{pseudo}</strong> devient un%{e} <em>vrai%{e}</em> icarien%{ne} !</span>'.freeze
})

ERRORS.merge!({
  express_checkout_failure: 'Un problème est malheureusement survenu (%{short} : %{long}).'.freeze
})
