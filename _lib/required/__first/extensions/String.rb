# encoding: UTF-8
class String

  def nil_if_empty
    if self == ''
      nil
    else
      self
    end
  end

  def titleize
    str = self.downcase
    str[0] = str[0].upcase
    str
  end #/ titleize

  def camelize
    self.split('_').collect{|m| m.titleize}.join('')
  end #/ camelize

end #/String
