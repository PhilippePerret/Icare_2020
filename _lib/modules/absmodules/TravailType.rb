# encoding: UTF-8
class TravailType < ContainerClass
class << self

  # Contrairement aux autre classes, on prend les travaux-type par leur
  # rubrique-short_name
  def get rubrique, short_name
    @items ||= {}
    @items["#{rubrique}-#{short_name}"] ||= begin
      dttype = db_get('abs_travaux_type', {rubrique:rubrique, short_name:short_name})
      dttype || raise(ERRORS[:unfound_data] % {with:"rubrique:#{rubrique}, short_name:#{short_name}"})
      inst = new(dttype[:id])
      inst.data = dttype
      inst
    end
  end #/ get

  def table
    @table ||= 'abs_travaux_type'
  end #/ table

end # /<< self

end #/TravailType
