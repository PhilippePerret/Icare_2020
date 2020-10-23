# encoding: UTF-8
# frozen_string_literal: true
class Concours
  attr_accessor :res # pour engranger les résultats
  def proceed_operations_per_step(data_step, options = nil)
    require_relative './ConcoursStep'
    self.res = []
    istep = ConcoursStep.new(self, data_step)
    istep.run_operations
    @resultat = res.join(BR)
  end #/ proceed_operations_per_step
end
