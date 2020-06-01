# encoding: UTF-8
class IcModule < ContainerClass
class << self

  def table
    @table ||= 'icmodules'
  end #/ table

  # Méthode qui crée un module pour l'icarien data[:user]
  # +data+
  #     :user           {User|Integer} L'icarien du module ou son identifiant
  #     :absmodule_id   {Integer} Identifiant du module
  #
  # Retourne l'icmodule créé.
  #
  def create(data)
    data[:user] = User.get(data[:user]) if data[:user].is_a?(Integer)

    # Quel que soit le module, un watcher de paiement
    # TODO
  end #/ create

end # /<< self

# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------

def absmodule
  @absmodule ||= AbsModule.get(data[:absmodule_id])
end #/ absmodule

end #/IcModule
