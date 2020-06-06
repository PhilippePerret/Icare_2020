# encoding: UTF-8
class AbsModule < ContainerClass
class << self

  def table
    @table ||= 'absmodules'
  end #/ table

end # /<< self

# Retourne l'absetape du module correspondant au numéro +numero+
def get_absetape_by_numero(numero)
  detape = db_get('absetapes', {absmodule_id:id, numero:numero}, {columns:[:id]})
  unless detape.nil?
    AbsEtape.get(detape[:id])
  else nil end
end #/ get_absetape_by_numero

end #/IcModule
