# encoding: UTF-8
=begin
  Constantes pour la destruction
=end
require './_lib/required/__first/constants/emojis'

UI_TEXTS.merge!({
  btn_detruire_definitivement_profil: "Détruire définitivement mon profil",
})
ERRORS.merge!({
  password_required: 'Vous devez fournir votre mot de passe afin que je puisse m’assurer que c’est bien vous.'.freeze,
})

MESSAGES.merge!({
  destroy_confirm: 'Votre profil a été détruit avec succès, %{pseudo} (et c’est la dernière fois que je prononce votre pseudo '+Emoji.get('smileys/larme').texte+').'
})
