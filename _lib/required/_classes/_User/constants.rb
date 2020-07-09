# encoding: UTF-8
=begin

=end
class User

# Les données pour le statut de l'icarien (son bit 16)
DATA_STATUT = {
  0 => :undefined, 1 => :guest, 2 => :actif, 3 => :candidat, 4 => :inactif, 5 => :destroyed, 6 => :recu,  8 => :pause,
  undefined:  {value:0, name:'indéfini'.freeze},
  guest:      {value:1, name:'invité'.freeze},
  actif:      {value:2, name:'actif'.freeze},
  candidat:   {value:3, name:'candidat'.freeze},
  inactif:    {value:4, name:'inactif'.freeze},
  destroyed:  {value:5, name:'détruit'.freeze},
  recu:       {value:6, name:'reçu'.freeze},
  pause:      {value:8, name:'en pause'.freeze}
}
end #/User
