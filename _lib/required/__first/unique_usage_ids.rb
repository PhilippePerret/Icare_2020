# encoding: UTF-8
=begin
  Module pour les IDs à usage unique
=end
unless defined?(MyDB)
  unless defined?(OFFLINE)
    ONLINE  = ENV['HTTP_HOST'] != "localhost"
    OFFLINE = !ONLINE
  end
  require_relative 'db'
  require './_lib/data/secret/mysql'
  MyDB.DBNAME = OFFLINE ? 'icare_test' : 'icare_db'
end

class UUID
class << self
  # = main =
  # Méthode principale pour créer un nouvel enregistrement dans la table
  def create(data)
    data.merge!(uuid: rand(32700))
    db_compose_insert(table, data)
    if MyDB.error
      raise MyDB.error.inspect
    else
      return data
    end
  end #/ create
  # = main =
  # Méthode principale qui retourne TRUE si tout est OK et false dans le cas
  # contraire.
  def check(uuid, uid, sessid, scope = nil)
    record = get_by_uuid(uuid) || begin
      log("UUID Bad uuid (inexistant)")
      return false
    end
    record[:session_id] == sessid || begin
      log("UUID Bad Session-id (#{record[:session_id]}/#{sessid.inspect})")
      return false
    end
    record[:user_id] == uid || begin
      log("UUID Bad User-id (#{record[:user_id]}/#{uid.inspect})")
      return false
    end
    if scope && record[:scope] != scope
      log("UUID Bad Scope (#{record[:scope]})/#{scope}")
      return false
    end
    return true # tout est OK
  end #/ check
  # On fournit l'UUID et on récupère l'enregistrement
  def get_by_uuid(uuid)
    db_get(table,{uuid: uuid})
  end #/ get_by_uuid
  def get_by_user(uid)
    db_get(table,{user_id: uid})
  end #/ get_by_user
  def table
    @table ||= 'unique_usage_ids'.freeze
  end #/ table
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def initialize

end #/ initialize
end #/UUID
