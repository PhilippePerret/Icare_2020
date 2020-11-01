# encoding: UTF-8
# frozen_string_literal: true
require_relative './Operation'

class Concours
  def proceed_operations_per_phase(data_phase, options = nil)
    options ||= {}
    options.merge!(format: 'html')
    require_relative './ConcoursPhase'
    iphase = ConcoursPhase.new(self, data_phase)
    iphase.run_operations(options)
    iphase.checke
  end #/ proceed_operations_per_phase
end
