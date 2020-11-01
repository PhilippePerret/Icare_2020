# encoding: UTF-8
# frozen_string_literal: true
class Concours
  def change_phase
    @phase = param(:current_phase).to_i
    save(phase: @phase)
    require_relative './proceed_operations_per_phase'
    options = {}
    if param(:doit) == "1"
      options.merge!(doit: true) # do it
    else
      options.merge!(noop: true)
    end
    proceed_operations_per_phase(PHASES_DATA[@phase].merge(phase: @phase), options)
  end #/ change_phase
end
