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
    require_module('watchers')
    # L'icarien concerné (possesseur du module)
    icarien = data[:user]
    icarien = User.get(icarien) if icarien.is_a?(Integer)

    # On ajoute l'identifiant du module (pour le watcher)
    data.merge!(objet_id: db_last_id)

    # Quel que soit le module, un watcher de démarrage
    icarien.watchers.add(:creation_icmodule, data)
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
