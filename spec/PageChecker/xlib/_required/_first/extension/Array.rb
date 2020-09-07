# encoding: UTF-8
# frozen_string_literal: true
class Array
  def to_sym(deep = false)
    self.collect do |v|
      if deep
        v = case v
        when Hash
          v.to_sym(deep = true)
        when Array
          v.to_sym(deep = true)
        else
          v
        end
      end
    end
  end #/ to_sym

end #/Array
