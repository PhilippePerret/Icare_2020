# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module des constants
=end

VERBOSE = IcareCLI.option?(:verbose)

MESSAGES.merge!({
  question_check: "Qu'est que je dois checker ?"
})

DATA_WHAT_CHECK = [
  {name: "Tout (user, modules, etc.)", value: :all},
  {name: "Les icariens", value: :users},
  {name: "Les modules", value: :modules}
]

class DataCheckedError < StandardError
  class << self
    attr_reader :errors # liste de toutes les erreurs
    attr_accessor :current_owner # pour définir le propriétaire courant de l'erreur
    def add_error(err)
      @errors ||= []
      @errors << err
    end #/ add_error
  end #/<< self

  attr_reader :owner # le propriétaire de l'erreur (module, étape, etc.)
  attr_reader :message
  def initialize err_msg, values = nil
    if values.nil?
      @message = err_msg
    else
      @message = err_msg % values
    end
    @owner = self.class.current_owner
    self.class.add_error(self)
  end #/ initialize
  def full_message
    "##{TABU}ERREUR : #{@message}"
  end #/ message
end

RESULTATS = {
  absmodule_required: {
    success: "Le module absolu est défini",
    failure: "Le module devrait définir son absmodule_id…"
  },
  icmodule_id_required:{
    success: "L’identifiant du module icarien est défini",
    failure: "L’identifiant du module icarient (icmodule_id) est requis"
  },
  icmodule_exists: {
    success: "Le module icarien #%i existe.",
    failure: "Le module icarien #%i devrait exister…"
  },
  finished_if_last_etape_ended: {
    success: "Le module icarien est marqué fini car sa dernière étape est marquée finie.",
    failure: "Le module icarien devrait être marqué fini car sa dernière étape est finie…"
  },
  absmodule_exists: {
    success: "Le module absolu #%i existe.",
    failure: "Le module absolu #%i est inconnu…"
  },
  absetape_id_required: {
    success: "L’identifiant de l'étape absolue est défini.",
    failure: "L'étape devrait définir son étape absolue"
  },
  absetape_exists: {
    success: "L’étape absolue #%i existe.",
    failure: "L’étape absolue #%i est inconnue…"
  },
  date_fin_defined_if_not_last: {
    success: "La date de fin est définie car ce n'est pas la dernière étape d'un module en cours…",
    failure: "La date de fin devrait être définie puisque %s (%s)…"
  },
  owner_required: {
    success: "La propriété user_id est définie",
    failure: "Le propriétaie (user_id) devrait être défini."
  },
  owner_exists: {
    success: "L’icarien #%i existe",
    failure: "Le propriétaire #%{user_id} est inconnu…",
    reparer: "Mettre l'icarien anonyme #9",
    request: "UPDATE icmodules SET user_id = 9 WHERE id = %{id};"
  },
  module_and_etape_same_owner: {
    success: "Le module et l'étape ont le même propriétaire",
    failure: "Le module et l'étape devraient avoir le même propriétaire (#%i pour le module, #%i pour l'étape)"
  },
  module_not_ended_not_end_time: {
    success: "Le module est en cours, pas de date de fin définie.",
    failure: "le module n'est pas terminé, mais sa date de fin est définie.",
    reparer: "Mettre l'icmodule du propriétaire à null.",
    request: "UPDATE users SET icmodule_id = NULL WHERE id = %{user_id};"
  },
  module_ended_with_end_time: {
    success: "Le module est terminé et sa date de fin est bien définie.",
    failure: "le module est terminé, mais sa date de fin n'est pas définie.",
    reparer: "Mettre sa date de fin (ended_at) à la date de fin de la dernière étape.",
    request: "UPDATE icmodules SET ended_at = '%{date}' WHERE id = %{id};"
  },
  module_current_not_affected: {
    success: nil,
    failure: "Le module en cours n'est pas affecté.",
    reparer: "Régler le icmodule_id du propriétaire.",
    request: "UPDATE user SET icmodule_id = %{id} WHERE id = %{user_id};"
  },
  has_one_etape: {
    success: "Le module a au moins une étape (il en a %{nombre})",
    failure: "Le module devrait avoir au moins une étape…",
    reparer: "Destruction du module et icmodule_id du propriétaire mis à NULL le cas échéant",
    request: "DELETE FROM icmodules WHERE id = %{id};#{RC}UPDATE users SET icmodule_id = NULL WHERE id = %{user_id} AND icmodule_id = %{id};"
  },
}

TABU = "    "

# POINT_VERT = ".".vert
POINT_ROUGE = ".".rouge
