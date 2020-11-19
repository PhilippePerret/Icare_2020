# encoding: UTF-8
=begin
  Extension de la class Integer
=end
class Integer

  def nil_if_empty
    if self == 0
      nil
    else
      self
    end
  end #/ nil_if_empty

  def days
    self * 24 * 3600
  end #/ days
  alias :day :days

  def weeks
    self * 7.days
  end #/ weeks
  alias :week :weeks

end #/Integer
