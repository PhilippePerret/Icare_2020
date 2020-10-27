# encoding: UTF-8
# frozen_string_literal: true
class String

  def nil_if_empty
    str = self.strip
    str == "" ? nil : str
  end #/ nil_if_empty
  
end #/String
