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
  {name: "les modules", value: :modules}
]

class DataCheckedError < StandardError
  def initialize key_error, values = nil
    if values.nil?
      @message = ERRORS[key_error]
    else
      @message = ERRORS[key_error] % values
    end
  end #/ initialize
  def message
    @message
  end #/ message
end

ERRORS.merge!({
  absmodule_id_required: "Le module devrait définir son absmodule_id…",
  absmodule_unknown: "Le module absolu %i est inconnu…",
  owner_required: "Le propriétaie (user_id) devrait être défini.",
  owner_unknown: "Le propriétaire %i est inconnu…",
  module_bad_end_state: "Le module n'a pas le bon état : %s",
  one_etape_required: "Le module devrait avoir au moins une étape…",
})

TABU = "    "
