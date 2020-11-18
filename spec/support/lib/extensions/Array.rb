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

  def pretty_join(inspecter = true)
    if self.count == 1
      seul = self.first
      seul = seul.inspect if inspecter
      seul
    elsif self.count == 0
      return nil
    else
      ary = self.dup
      dernier = ary.pop
      dernier = dernier.inspect if inspecter
      ary = (inspecter ? ary.collect{|m|m.inspect} : ary).join(', ')
      ary + ' et ' + dernier
    end
  end #/ pretty_join
end #/Array
