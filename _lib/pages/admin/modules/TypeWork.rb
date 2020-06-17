# encoding: UTF-8
=begin
  Pour l'édition des travaux-types
=end
class TypeWork < ContainerClass
class << self
  def get(rubrique, name)
    # TODO Retourne l'instance du travail type
  end #/ get
  def table
    @table ||= 'abstravauxtypes'
  end #/ table
end # /<< self

end #/TypeWork
