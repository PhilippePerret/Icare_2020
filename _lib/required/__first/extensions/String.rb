# encoding: UTF-8
class String

  def numeric?
    Float(self) != nil rescue false
  end
    
  def nil_if_empty
    if self == ''
      nil
    else
      self
    end
  end

  def sanitize
    self.gsub(/\r\n/, "\n")
  end #/ sanitize

  def titleize
    str = self.downcase
    str[0] = str[0].upcase
    str
  end #/ titleize

  def camelize
    self.split('_').collect{|m| m.titleize}.join('')
  end #/ camelize

  # Supprime toutes les balises HTML (pour les textes donnés)
  def safetize
    self.gsub(/<(.+?)>/, EMPTY_STRING)
  end #/ safetize

end #/String
