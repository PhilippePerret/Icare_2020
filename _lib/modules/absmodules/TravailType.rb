# encoding: UTF-8
class TravailType < ContainerClass

DEFAULT_DATA.merge!({
  name:nil, rubrique:nil, titre:nil, objectif:nil, methode:nil, liens:nil
})

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

  # On peut obtenir les travaux-type par leur rubrique-name
  def get_by_name rubrique, name
    @items_by_name ||= {}
    @items_by_name["#{rubrique}-#{name}"] ||= begin
      dttype = db_get('abstravauxtypes', {rubrique:rubrique, name:name})
      dttype || raise(ERRORS[:unfound_data] % {with:"rubrique:#{rubrique}, name:#{name}"})
      inst = new(dttype[:id])
      inst.data = dttype
      inst
    end
  end #/ get

  def table
    @table ||= 'abstravauxtypes'
  end #/ table

end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# La méthode de sauvegarde des travaux types est différente car l'identifiant
# se fait avec rubrique/name (ce qui est stupide… et si on profitait du chan
# gement pour rectifier ça ?)

end #/TravailType
