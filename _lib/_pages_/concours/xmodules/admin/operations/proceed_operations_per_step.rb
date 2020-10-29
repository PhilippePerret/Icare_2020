# encoding: UTF-8
# frozen_string_literal: true
require_relative './Operation'

class Concours
  def proceed_operations_per_step(data_step, options = nil)
    options ||= {}
    options.merge!(format: 'html')
    require_relative './ConcoursStep'
    istep = ConcoursStep.new(self, data_step)
    istep.run_operations(options)
  end #/ proceed_operations_per_step
end
