# encoding: UTF-8
# frozen_string_literal: true
class Hash
  def pretty_inspect(level = 0)
    res = []
    self.each do |k, v|
      vh = v.respond_to?(:pretty_inspect) ? v.pretty_inspect(level+1) : v.inspect
      res << "#{"\t"*level}#{k.inspect} => #{vh}"
    end
    res.join("\n")
  end #/ pretty_inspect
end #/Hash
