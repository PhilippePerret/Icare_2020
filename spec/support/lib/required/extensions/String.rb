# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension pour les chaines de caractères
=end
require './_lib/required/__first/constants/String'
class String

  def strip_tags
    self.gsub(/<.*?>/,'')
  end #/ strip_tags

  def nil_if_empty
    self.strip unless self.empty?
  end #/ nil_if_empty
end #/String
