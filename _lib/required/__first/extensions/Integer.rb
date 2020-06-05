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
end #/Integer
