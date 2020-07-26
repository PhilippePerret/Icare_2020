# encoding: UTF-8
=begin
  Constantes pour le changement de mot de passe
=end
require './_lib/pages/user/signup/constants_messages'

UI_TEXTS.merge!({
  btn_change_password: "Changer le mot de passe".freeze,
})

ERRORS.merge!({
  oldpass_required: 'Votre mot de passe courant est requis !'.freeze,
  oldpass_invalide: 'Votre mot de passe est invalide. Merci de le vérifier.'.freeze,
  newpass_required: 'Le nouveau mot de passe est requis !'.freeze,
  newpass_invalide: 'Le nouveau mot de passe est invalide : %s.'.freeze,
})
