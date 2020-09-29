# encoding: UTF-8
# frozen_string_literal: true
=begin
  Études de cas des documents
=end
class CheckedDocument < ContainerClass
CHECKCASES = [
{
  description: "Le document définit user_id",
  condition:[],
  check: -> (objet) { objet.user_id != nil },
  success_message: "%{ref} définit user_id.",
  failure_message: "#ED1: %{ref} devrait définir user_id",
  reparation: :reparation_manuelle
},
{
  description: "Le propriétaire du document existe.",
  condition: [:has_user_id],
  check: -> (objet) { CheckedUser.exists?(objet.user_id)},
  success_message: "Le propriétaire de %{ref} existe : %{owner_ref}.",
  failure_message: "#ED2: Le propriétaire de %{ref} est introuvable…",
  reparation: -> (objet) {
    if objet.owner_possible.nil?
      # Noter que la méthode owner_possible pourra proposer des choix dans
      # lesquels choisir un module et donc un user.
      :reparation_manuelle
    else
      objet.set(user_id: objet.owner_possible.id)
      "Propriétaire mis à #{objet.owner_possible.ref}"
    end
  },
  simulation: -> (objet) {
    if objet.owner_possible.nil?
      "La réparation ne peut pas se faire automatiquement mais des choix seront proposés."
    else
      "Application de l'icarien trouvé : #{objet.owner_possible.ref}"
    end
  }
},
{
  description: "Le document définit son étape.",
  condition: [],
  check: -> (objet) { objet.icetape_id != nil},
  success_message: "%{ref} définit bien son icetape_id.",
  failure_message: "#ED3: %{ref} devrait définir son icetape_id…",
  reparation: :reparation_manuelle,
  simulation: "TODO : plus tard, la retrouver par rapport aux dates"
},
{
  description: "L'étape icarien du document existe.",
  condition: [:has_icetape_id],
  check: -> (objet) {CheckedEtape.exists?(objet.icetape_id)},
  success_message: "L'IcEtape de %{ref} existe bien.",
  failure_message: "#ED4: L’IcEtape de %{ref} (#%{icetape_id}) devrait exister…",
  reparation: :reparation_manuelle,
  simulation: "TODO : plus tard, la retrouver par rapport aux dates"
},
{
  description: "Le document a le même propriétaire que son étape",
  condition: [:has_owner, :has_icetape],
  check: -> (objet) { objet.icetape.user_id == objet.user_id},
  success_message: "Le %{ref} et son icétape ont le même propriétaire.",
  failure_message: "#ED5: Le %{ref} et son Icétape (d'icarien %{icetape_user_id}) devrait avoir le même propriétaire…",
  reparation: -> (objet) {
    # Soit on met le user_id du document à celui de l'étape (s'il est défini)
    # soit on met l'user_id du document à l'étape s'il n'est pas défini
    # Note : c'est un exemple de changement des données de l'étape au moment du
    # check des documents.
    if not(objet.icetape.user_id.nil?)
      objet.set(user_id: objet.icetape.user_id)
    else
      objet.icetape.set(user_id: objet.user_id)
    end
  },
  simulation: "L'user_id de l'étape, si elle existe, sera appliquée au document. Sinon, si l'user_id du document existe, il sera appliqué à l'étape."
},
{
  description: "Le document possède un nom original",
  condition:[],
  check: -> (objet) { objet.original_name != nil},
  success_message: "Le %{ref} possède un nom original (“%{original_name}”).",
  failure_message: "#ED6: Le %{ref} devrait posséder un nom original…",
  reparation: -> (objet) {
    # On lui fabrique un nom d'après ses données
    objet.set(original_name: original_name_composed)
  },
  simulation: -> (objet) {
    "Le nom “#{original_name_composed}” va lui être affecté."
  }
},
{
  description: "Si le document est déposé sur le QDD, on doit le trouver",
  condition: [:has_status_on_qdd],
  check: -> (objet) { objet.document_exists_on_qdd },
  success_message: "Le %{ref} existe sur le quai des docs.",
  failure_message: "Le %{ref} devrait exister sur le quai des docs…",
  reparation: :reparation_manuelle
},
]
end #/CheckedDocument < ContainerClass
