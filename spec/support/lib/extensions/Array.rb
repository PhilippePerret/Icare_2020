# encoding: UTF-8
# frozen_string_literal: true
class Array
  def nil_if_empty
    if self.empty?
      nil
    else
      self
    end
  end #/ nil_if_empty
end #/Array
