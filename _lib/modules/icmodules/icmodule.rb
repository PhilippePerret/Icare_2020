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
    valeurs = data.values
    columns = data.keys.join(VG)
    interro = Array.new(valeurs.count,'?').join(VG)
    request = "INSERT INTO `icmodules` (#{columns}) VALUES (#{interro})"
    db_exec(request, valeurs)
    return db_last_id
  end #/ create_in_db

end # /<< self

# ---------------------------------------------------------------------
#
#     INSTANCE
#
# ---------------------------------------------------------------------

def absmodule
  @absmodule ||= AbsModule.get(data[:absmodule_id])
end #/ absmodule

def name
  @name ||= absmodule.name
end #/ name

end #/IcModule
