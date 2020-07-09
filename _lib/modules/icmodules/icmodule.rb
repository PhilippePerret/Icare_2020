# encoding: UTF-8
require_module('absmodules')
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
  def create_new_for(data)
    require_module('watchers') unless defined?(Watcher)
    owner = data.delete(:user)
    data[:user_id] ||= owner.id
    # On crée l'enregistrement dans la table
    icmodule_id = create_in_db(data)
    # Quel que soit le module, un watcher de démarrage
    owner.watchers.add(:start_module, {objet_id: icmodule_id})
    return icmodule_id
  end #/ create

  def create_in_db(data)
    now = Time.now.to_i
    data.merge!(
      options:    '0'*16,
      created_at: now,
      updated_at: now
    )
    new_id = db_compose_insert('icmodules', data)
    return new_id
  end #/ create_in_db

end # /<< self

# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------
def ref
  @ref ||= "module “#{name}”#{f_id}"
end #/ ref

def suivi?
  absmodule.suivi?
end #/ suivi?

def absmodule
  @absmodule ||= AbsModule.get(data[:absmodule_id])
end #/ absmodule

def name
  @name ||= absmodule.name
end #/ name

# Étape courante
def icetape
  @icetape ||= IcEtape.get(icetape_id)
end #/ icetape

end #/IcModule
