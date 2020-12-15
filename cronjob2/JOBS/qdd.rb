# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tout ce qui concerne le Quai des Documents
=end
class Cronjob

  def data
    @data ||= {
      name: "Contrôle et réparation du QDD",
      frequency: {hour: 2}
    }
  end #/ data

  def qdd
    require_relative './qdd/required'
    require_relative './qdd/control.rb'
    QDD.control
    return true
  end

end #/Cronjob
