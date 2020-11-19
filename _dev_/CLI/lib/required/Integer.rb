# encoding: UTF-8
# frozen_string_literal: true
class Integer

  def hours
    self * 3600
  end #/ hours
  alias :hour :hours

  def days
    self * 24.hours
  end #/ days
  alias :day :days

end #/Integer
