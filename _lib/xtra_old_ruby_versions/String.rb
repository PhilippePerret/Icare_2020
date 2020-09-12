class String

  def match?(reg)
    self.match(reg) ? true : false
  end #/ match?(reg)


end #/String

if not String.new.respond_to?(:unpack1)
  class String
    def unpack1(fmt)
      self.unpack(fmt).first
    end #/ unpack1
  end #/String
end
