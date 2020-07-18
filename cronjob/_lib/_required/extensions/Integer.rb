class Integer

  # Pour faire "10.hours"
  def hours
    self * 3600
  end #/ hours
  alias :hour :hours

  def days
    self * 24.hours
  end #/ days
  alias :day :days

  def months
    self * 31.days
  end #/ months
  alias :month :months

end #/Integer
