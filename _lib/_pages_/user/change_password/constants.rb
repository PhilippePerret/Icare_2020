# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes pour le changement de mot de passe
=end
require "#{FOLD_REL_PAGES}/user/signup/constants_messages"

UI_TEXTS.merge!({
  btn_change_password: "Changer le mot de passe",
})

ERRORS.merge!({
  oldpass_required: 'Votre mot de passe courant est requis !',
  oldpass_invalide: 'Votre mot de passe est invalide. Merci de le vérifier.',
  newpass_required: 'Le nouveau mot de passe est requis !',
  newpass_invalide: 'Le nouveau mot de passe est invalide : %s.',
})
