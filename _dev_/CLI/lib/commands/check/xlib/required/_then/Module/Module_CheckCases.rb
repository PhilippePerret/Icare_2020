# encoding: UTF-8
# frozen_string_literal: true
class CheckedModule
CHECKCASES = [

{
  description: "L'user_id du module est défini",
  condition: [],
  check: -> (objet) { objet.user_id != nil },
  success_message: "L’%{ref} définit un propriétaire.",
  failure_message: "L’%{ref} devrait définir un propriétaire.",
  reparation: :reparation_manuelle
},
{
  description: "L'user_id du module existe et concerne un icarien existant",
  condition: [:has_user_id],
  check: -> (objet) { CheckedUser.exists?(objet.user_id) },
  success_message: "Le propriétaire du %{ref} existe.",
  failure_message: "Le propriétaire du L’%{ref} est inexistant…",
  reparation: :reparation_manuelle
},
{
  description: "Définition de son module absolu (absmodule_id)",
  condition: [],
  check: -> (obj) { obj.absmodule_id != nil },
  success_message: "L'absmodule_id de %{ref} est défini",
  failure_message: "L'absmodule_id de %{ref} devrait être défini",
  reparation: :reparation_manuelle
},
{
  description: "Existence de son module absolu",
  condition: [:has_absmodule_id],
  check: -> (obj) { db_count('absmodules', {id: obj.absmodule_id}) == 1},
  success_message: "Le module absolu de %{ref} existe",
  failure_message: "Le module absolu de %{ref} (#%{absmodule_id}) est introuvable",
  reparation: :reparation_manuelle
},
{
  description: "Il doit avoir au moins une étape",
  condition: [:is_started],
  check: -> (objet) { objet.icetapes.count > 0 },
  success_message: "Le %{ref} a au moins une étape de travail",
  failure_message: "Le %{ref} devrait avoir au moins une étape de travail",
  simulation: "Il faut simplement le détruire car c'est une erreur…",
  reparation: -> (objet) { db_exec("DELETE FROM icmodules WHERE id = ?", objet.id) }
},
{
  description: "Si c'est le module courant, il ne doit pas être fini",
  condition: [:has_owner, :is_current_module_of_user],
  check: -> (objet) { objet.ended_at == nil },
  success_message: "Le module courant n'est pas encore fini.",
  failure_message: "Le module courant ne devrait pas être marqué fini…",
  reparation: -> (objet) { objet.owner.set(icmodule_id: nil)},
  simulation: "L’icmodule_id du propriétaire de %{ref} doit être mis à NIL."
},
{
  description: "Si ce n'est pas le module courante du propriétaire, il doit être fini",
  condition: [:has_owner, :not_current_module_of_user],
  check: -> (objet) { objet.ended_at != nil },
  success_message: "Le %{ref} est bien fini",
  failure_message: "Le %{ref} devrait être marqué fini (ended_at)…",
  reparation: -> (objet) {
    last_etape = objet.icetapes.last
    adate = last_etape.ended_at || last_etape.expected_end || ((last_etape.created_at || last_etape.updated_at).to_i + 4.days)
    data_last_etape = {}
    data_last_etape.merge!(ended_at: adate)   if last_etape.ended_at.nil?
    data_last_etape.merge!(created_at: adate) if last_etape.created_at.nil?
    data_last_etape.merge!(updated_at: adate) if last_etape.updated_at.nil?
    unless data_last_etape.empty?
      last_etape.set(data_last_etape)
    end
    objet.set(ended_at: adate.to_s)
  },
  simulation: -> (objet) {
    last_etape = objet.icetapes.last
    puts "last_etape.data = #{last_etape.data.inspect}"
    adate = last_etape.ended_at || last_etape.expected_end || ((last_etape.created_at || last_etape.updated_at).to_i + 4.days)
    return "L'ended_at du %{ref} doit être mis à la date de fin de sa dernière étape : #{adate}."
  }
}
]
end #/CheckedModule
