# encoding: UTF-8
class AbsModule < ContainerClass
class << self
  def table
    @table ||= 'absmodules'
  end #/ table

  # Pour obtenir un select complet
  #
  # +parameters+
  #   :titre      Le texte du premier menu
  #   :id         Identifiant optionnel
  #   :name       Le name optionnel
  #   :class      La class CSS optionnelle
  #
  def menu_select(parameters = nil)
    parameters ||= {}
    parameters.key?(:titre) || parameters.merge!(titre: 'Voir le module…'.freeze)
    parameters.merge!(options: menus_modules(parameters))
    [:class, :id, :name].each do |prop|
      parameters.key?(prop) || parameters.merge!(prop => '')
    end
    TAG_SELECT_SIMPLE % parameters
  end #/ select

  # Retourne les OPTIONS à placer dans un select des modules
  # +pms+
  #   :titre    Pour définir le premier menu (par défaut : "Voir le module…")
  #
  # Note : le fait d'offrir juste les options permet de régler le name et l'id
  # du select sans problème. On peut utiliser menu_select ci-dessus
  def menus_absmodule(pms = {})
    default_value = pms[:value] || pms[:default] || pms[:default_value]
    self.collect do |absmod|
      selected = (default_value == absmod.id) ? SELECTED : EMPTY_STRING
      TAG_OPTION % {value:absmod.id, selected:selected, titre:absmod.name}
    end.unshift(TAG_OPTION % {value:'', selected:'', titre:pms[:titre]||'Voir le module…'.freeze}).join
  end #/ menus_absmodule

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
alias :absetapes :etapes


# Retourne l'absetape du module correspondant au numéro +numero+
def get_absetape_by_numero(numero)
  detape = db_get('absetapes', {absmodule_id:id, numero:numero}, {columns:[:id]})
  unless detape.nil?
    AbsEtape.get(detape[:id])
  else nil end
end #/ get_absetape_by_numero

end #/IcModule
