# encoding: UTF-8
# frozen_string_literal: true
class CheckedEtape < ContainerClass
CHECKCASES = [
{
  description: "L'étape définit son ID d'étape absolue",
  condition: [],
  check: -> (objet) { objet.absetape_id != nil },
  success_message: "%{ref} définit son identifiant d'étape absolue.",
  failure_message: "%{ref} devrait définir son identifiant d'étape absolue…",
  reparation: :reparation_manuelle
},
{
  description: "L'étape possède une étape absolue",
  condition: [:has_absetape_id],
  check: -> (objet) { AbsEtape.exists?(objet.absetape.id) },
  success_message: "%{ref} possède une étape absolue existante.",
  failure_message: "L'étape absolue #%{absetape_id} de %{ref} n'existe pas…",
  reparation: :reparation_manuelle
},
{
  description: "L'étape définit son ID de module",
  condition: [],
  check: -> (objet) { objet.icmodule_id != nil},
  success_message: "%{ref} définit son IcModule.",
  failure_message: "%{ref} devrait définir son IcModule…",
  reparation: :reparation_manuelle
},
{
  description: "L'IcModule de l'étape est défini.",
  condition: [:has_icmodule_id],
  check: -> (objet) { CheckedModule.exists?( objet.icmodule_id) },
  success_message: "%{ref} appartient à la IcModule existant.",
  failure_message: "L'IcModule de %{ref} est introuvable…",
  reparation: :reparation_manuelle
},
{
  description: "Le propriétaire de l'étape doit être défini",
  condition: [],
  check: -> (objet) { objet.user_id != nil },
  success_message: "%{ref} définit bien son user_id.",
  failure_message: "%{ref} devrait définir son user_id…",
  reparation: -> (objet) {
    uid = objet.icmodule.user_id
    uid.nil? ? :reparation_manuelle : objet.set(user_id: uid)
  },
  simulation: -> (objet) {
    if objet.icmodule.user_id.nil?
      :reparation_manuelle
    else
      "L'user_id peut être pris de l'icmodule parent."
    end
  }
},
{
  description: "Le propriétaire doit exister.",
  condition: [:has_user_id],
  check: -> (objet) { CheckedUser.exists?(objet.user_id) },
  success_message: "Le propriétaire de %{ref} existe bien.",
  failure_message: "Le propriétaire de %{ref} est inconnu…",
  reparation: :reparation_manuelle
},
{
  description: "Le propriétaire de l'étape est le même que celui du module",
  condition: [:has_owner, :has_module],
  check: -> (objet) { objet.icmodule.user_id == objet.user_id },
  success_message: "L’%{ref} a le même propriétaire que son module (%{user_ref}).",
  failure_message: "L’%{ref} n'a pas le même propriétaire que son module…",
  reparation: -> (objet) { objet.define_good_owner},
  simulation: -> (objet) {
    if objet.has_owner && objet.icmodule.has_owner
      "Les deux propriétaires seront proposés au choix."
    elsif objet.icmodule.has_owner
      "Le propriétaire du module sera appliqué à l'%{ref}."
    elsif objet.has_owner
      "Le propriétaire de l'%{ref} sera appliqué à son module."
    else
      "Le propriétaire devra être choisi par les propriétaires du moment."
    end
  }
},
{
  description: "L'étape définit son status",
  condition: [],
  check: -> (objet) { objet.status != nil },
  success_message: "%{ref} définit son statut.",
  failure_message: "%{ref} devrait définir son statut.",
  reparation: -> (objet) { objet.reparer_status(any: true) },
  simulation: "Calcul du statut à appliquer à %{ref}."
},
{
  description: "Le statut de l'étape est valide.",
  condition: [:has_status],
  check: -> (objet) { objet.check_status_value },
  success_message: "Le status de %{ref} possède la bonne valeur.",
  failure_message: "Le status de %{ref} n'est pas conforme aux informations trouvées : %{error}.",
  reparation: -> (objet) { objet.reparer_status(any: true) },
  simulation: "Calcul du bon statut à appliquer à %{ref}."
},
{
  description: "Si ce n'est pas la dernière étape, elle doit être marquée finie",
  condition: [:is_not_last_etape],
  check: -> (objet) { objet.ended_at != nil && objet.status && objet.status >= 6 },
  success_message: "L’%{ref} est bien terminée.",
  failure_message: "L’%{ref} n'est pas bien marquée terminée (ended_at ou status).",
  reparation: -> (objet) {
    if objet.ended_at
      objet.reparer_ended_at
    end
    if objet.status && objet.status < 6
      objet.set(status: 8) || :reparation_manuelle
    else
      :reparation_manuelle
    end
  },
  simulation: -> (objet) {
    # Retourne le message
    objet.can_reparer_status? || :reparation_manuelle
  }
},
{
  description: "Si l'étape est finie (ended_at défini), son statut doit être de 8",
  condition:[:is_finished],
  check: -> (objet) { objet.status == 8 },
  success_message: "L'%{ref} finie possède bien le statut 8.",
  failure_message: "L’%{ref} est finie, elle devrait posséder le statut 8…",
  reparation: -> (objet) { objet.set(status: 8) },
  simulation: "Le statut de l’%{ref} sera mis à 8."
},
{
  description: "Si c'est la dernière étape du module courant, elle ne doit pas être finie.",
  condition: [:is_current_etape_of_current_module],
  check: -> (objet) { objet.ended_at == nil },
  success_message: "L'étape courante (%{ref}) du module courant est bien en cours de travail (non finie).",
  failure_message: "L'étape courante (%{ref}) du module courant ne devrait pas être marquée finie…",
  reparation: -> (objet) { objet.set(ended_at: nil)},
  simulation: "Mise à nil de l'ended_at de l'étape."
},
{
  description: "L'étape ne doit pas avoir de watchers incohérents",
  condition:[:has_watchers, :has_status],
  check: -> (objet) { objet.watchers_are_coherents },
  success_message: "Les watchers de %{ref} sont cohérents.",
  failure_message: "Les watchers de %{ref} ne sont pas cohérents : %{error}…",
  reparation: -> (objet) { objet.reparer_watchers(simuler=false) },
  simulation: -> (objet) { objet.reparer_watchers(simuler=true) }
}
]
end #/CheckedEtape < ContainerClass
