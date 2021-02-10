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

  def smart_merge(hash)
    h = self
    hash.each do |k, v|
      h.merge!(k => {}) unless h.key?(k)
      if v.is_a?(Hash)
        h[k] = h[k].smart_merge(v)
      else
        h[k] = v
      end
    end
    return h
  end #/ smart_merge

  def smart_merge!(hash)
    self.replace(self.smart_merge(hash))
  end #/ smart_merge!

end #/Hash
