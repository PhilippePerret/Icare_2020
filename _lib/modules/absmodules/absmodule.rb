# encoding: UTF-8
class AbsModule < ContainerClass
class << self
  def table
    @table ||= 'absmodules'
  end #/ table
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Return TRUE si le module est un module de type suivi
def suivi?
  nombre_jours.nil?
end #/ suivi?

# Retourne la liste ordonnée des étapes (instances AbsEtape) du module
def etapes
  @etapes ||= begin
    request = "SELECT * FROM absetapes WHERE absmodule_id = #{id} ORDER BY numero".freeze
    db_exec(request).collect do |detape|
      AbsEtape.instantiate(detape)
    end
  end
end #/ etapes


# Retourne l'absetape du module correspondant au numéro +numero+
def get_absetape_by_numero(numero)
  detape = db_get('absetapes', {absmodule_id:id, numero:numero}, {columns:[:id]})
  unless detape.nil?
    AbsEtape.get(detape[:id])
  else nil end
end #/ get_absetape_by_numero

end #/IcModule
