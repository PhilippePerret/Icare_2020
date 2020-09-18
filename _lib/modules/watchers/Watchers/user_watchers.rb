# encoding: UTF-8
=begin
  Extension de User pour les watchers
  + Class Watchers
=end
class User
def watchers
  @watchers ||= Watchers.new(self)
end #/ watchers
end #/User

=begin
  Extension de User pour les watchers
  Attention, les classes MainWatchers (AdminWatchers et UserWatchers) ne
  sont pas à confondre avec la classe Watcher d'un watcher.
=end
# ---------------------------------------------------------------------
#
#   class UserWatchers
#
# ---------------------------------------------------------------------
class Watchers
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :owner
def initialize owner
  @owner = owner
end #/ initialize

# Retourne les watchers de l'user correspondant au filtre +filtre+ qui peut
# porter sur toutes les données du watcher.
# +options+
#     Permet de définir d'autres chose comme la limite ou l'odre
def find(filtre, options = nil)
  valeurs = [owner.id]
  where   = ["user_id = ?"]
  filtre.each do |k,v|
    where << "#{k} = ?"
    valeurs << v
  end
  request = "SELECT * FROM watchers WHERE #{where.join(' AND ')}"
  options ||= {}
  request << " LIMIT #{options[:limit]}".freeze if options.key?(:limit)
  request << " ORDER BY #{options[:order]}".freez if options.key?(:order)
  db_exec(request.freeze, valeurs).collect do |dwatcher|
    Watcher.instantiate(dwatcher)
  end
end #/ find

# Retourne tous les watchers du propriétaire
# Noter que cela comprend aussi les watchers automatiques
def all
  @all ||= begin
    where = "WHERE ( triggered_at IS NULL OR triggered_at < #{Time.now.to_i} )"
    where << " AND user_id = #{owner.id}".freeze unless owner.admin?
    request = "SELECT * FROM watchers #{where}".freeze
    db_exec(request).collect { |dwatcher| Watcher.instantiate(dwatcher) }
  end
end #/ all

# Méthode qui ajoute un watcher pour l'icarien, de type
# +wtype+ avec les données +data+
#   :params     Un hash de paramètres (qui sera jsonné)
#
# SI tout s'est bien passé, retourne l'ID du nouveau watcher
def add wtype, data = nil
  if wtype.is_a?(Hash)
    data = wtype
  else
    data.merge!(wtype: wtype.to_s)
  end
  now = Time.now.to_i
  vu_admin  = data[:vu_admin].nil? ? user.admin? : data[:vu_admin]
  vu_user   = data[:vu_user].nil? ? !user.admin? : data[:vu_user]
  dwatcher = {
    wtype:      data[:wtype], # par exemple 'commande_module'
    objet_id:   data[:objet_id],
    user_id:    owner.id,
    vu_admin:   vu_admin,
    vu_user:    vu_user,
    triggered_at: data[:triggered_at],
    params:     (data[:params].to_json if data[:params]),
    updated_at: now.to_s,
    created_at: now.to_s
  }
  # On procède à l'enregistrement dans la table
  valeurs = dwatcher.values
  columns = dwatcher.keys.join(VG)
  interro = Array.new(valeurs.count, '?').join(VG)
  request = "INSERT INTO watchers (#{columns}) VALUES (#{interro})"
  begin
    db_exec(request, valeurs)
    return db_last_id
  rescue MyDBError => e
    erreur(e.message)
  end
end #/ add

# Détruit tous les watchers de l'user correspondant aux données +data+ (qui
# seront envoyées à `find`)
def remove data
  ids = find(data).collect do |watcher| watcher.id end
  request = "DELETE FROM `watchers` WHERE id "
  request << ((ids.count == 1) ? "= #{ids.first}" : "IN (#{ids.join(VG)})")
  db_exec(request)
end #/ remove

def count
  all.count
end #/ count

# Retourne la liste des watchers lus par l'user
def read
  @read ||= begin
    filter_key = user.admin? ? :admin : :user
    all.select do |watcher|
      next unless watcher.vu_par?(filter_key)
      watcher
    end
  end
end #/ read

def unread
  # log("-> unread (@unread = #{@unread.inspect})")
  @unread ||= begin
    filter_key = user.admin? ? :admin : :user
    ur = all.select do |watcher|
      next false if watcher.vu_par?(filter_key)
      watcher
    end
    ur
  end
end #/ read

# Nombre de watchers non vus
def unread_count
  log("-> unread_count")
  @unread_count ||= unread.count
end #/ unread_count

def allmarkread
  prop = owner.admin? ? 'vu_admin'.freeze : 'vu_user'.freeze
  request = "UPDATE watchers SET #{prop} = TRUE WHERE #{prop} = FALSE"
  db_exec(request)
  message "Toutes vos notifications ont été marquées lues, #{owner.pseudo}.".freeze
end #/ allmarkread

end #/MainWatchers
