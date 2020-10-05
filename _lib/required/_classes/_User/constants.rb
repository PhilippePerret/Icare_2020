# encoding: UTF-8
# frozen_string_literal: true
=begin

=end
class User

# Les données pour le statut de l'icarien (son bit 16)
DATA_STATUT = {
  0 => :undefined, 1 => :guest, 2 => :actif, 3 => :candidat, 4 => :inactif, 5 => :destroyed, 6 => :recu,  8 => :pause,
  undefined:  {value:0, name:'indéfini'},
  guest:      {value:1, name:'invité'},
  actif:      {value:2, name:'actif',     icarien:true},
  candidat:   {value:3, name:'candidat',  icarien:true},
  inactif:    {value:4, name:'inactif',   icarien:true},
  destroyed:  {value:5, name:'détruit'},
  recu:       {value:6, name:'reçu',      icarien:true}, # reçu mais pas encore en activité
  pause:      {value:8, name:'en pause',  icarien:true}
}
end #/User

MESSAGES.merge!({
  confirmation_mail_required: "%s, vous devez confirmer votre adresse mail à l’aide du lien qui vous a été transmis par mail.<br>Vous avez perdu ce mail ? Rejoignez votre section “Notifications” pour vous renvoyer ce mail."
})
