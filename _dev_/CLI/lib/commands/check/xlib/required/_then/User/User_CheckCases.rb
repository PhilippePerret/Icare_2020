# encoding: UTF-8
# frozen_string_literal: true
=begin
  Définition des tests à appliquer à User
=end
class CheckedUser < ContainerClass
CHECKCASES = [
{
  description: "S'il a un icmodule_id défini, le statut de l'icarien doit être actif",
  condition: [:not_destroyed, :has_icmodule_id],
  check: -> (objet) { objet.options[16] == '2' },
  success_message: "%{ref} est bien marqué actif",
  failure_message: "%{ref} n'est pas actif, son icmodule_id devrait être nil",
  reparation: -> (objet) { objet.set(icmodule_id: nil) },
  simulation: "icmodule_id de %{ref} mis à NULL"
},
{
  description: "Un icarien inactif ne peut pas avoir de module courant",
  condition: [:not_destroyed, :is_inactif],
  check: -> (objet) { objet.icmodule_id === nil },
  success_message: "%{ref} est inactif, son icmodule_id est bien nil",
  failure_message: "%{ref} est inactif, son icmodule_id devrait être à nil",
  reparation: -> (objet) { objet.set(icmodule_id: nil) },
  simulation: "icmodule_id de %{ref} mis à NULL"
}
]
end #/CheckedUser