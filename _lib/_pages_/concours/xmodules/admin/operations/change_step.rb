# encoding: UTF-8
# frozen_string_literal: true
class Concours
  def change_step
    @step = param(:current_step).to_i
    save(step: @step)
    require_relative './proceed_operations_per_step'
    proceed_operations_per_step(STEPS_DATA[@step].merge(step: @step))
  end #/ change_step
end
