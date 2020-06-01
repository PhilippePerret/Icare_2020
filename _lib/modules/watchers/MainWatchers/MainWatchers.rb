# encoding: UTF-8
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
class MainWatchers
  attr_reader :owner
  def initialize owner
    @owner = owner
  end #/ initialize

  def count
    all.count
  end #/ count

  # Nombre de watchers non vus
  def non_vus_count
    @non_vus_count ||= unread.count
  end #/ non_vus_count

end #/MainWatchers

# ---------------------------------------------------------------------
#
#   Class pour l'administrateur
#
# ---------------------------------------------------------------------
class AdminWatchers < MainWatchers
  # Liste Array de tous les watchers
  def all
    @all ||= Watcher.get_all.values
  end #/ all

  # Liste des watchers non vus
  def unread
    @unread ||= begin
      all.collect do |w|
        next if w.vu?
        w
      end.compact
    end
  end #/ unread

  # Liste des watchers vus
  def read
    @read ||= all.collect do |w|
      next unless w.vu?
      w
    end.compact
  end #/ read

end #/AdminWatchers

# ---------------------------------------------------------------------
#
#   Class pour un icarien
#
# ---------------------------------------------------------------------
class UserWatchers < MainWatchers
  # Liste Array de tous les watchers
  def all
    @all ||= Watcher.watchers_of(owner)
  end #/ all

  # Méthode qui ajoute un watcher pour l'icarien, de type
  # +wtype+ avec les données +data+
  def add wtype, data
    dwatcher = DATA_WATCHERS[wtype]
    dwatcher.merge!({
      objet_id: data[:objet_id],
      user_id:  owner.id
      })
    required = dwatcher.delete(:required)
    dwatcher.merge!(vu_admin: false)  unless dwatcher.key?(:vu_admin)
    dwatcher.merge!(vu_user: false)   unless dwatcher.key?(:vu_user)
    now = Time.now.to_i
    dwatcher.merge!({
      updated_at: now,
      created_at: now
      })
    # On vérifie que toutes les valeurs soient bien fournies
    required.each do |prop|
      dwatcher.key?(prop) || raise("La clé #{k.inspect} doit être fournie.")
    end
    valeurs = dwatcher.values
    columns = dwatcher.keys.join(VG)
    interro = Array.new(valeurs.count, '?').join(VG)
    request = "INSERT INTO watchers (#{columns}) VALUES (#{interro})"
    db_exec(request, valeurs)
    if MyDB.error
      log(MyDB.error)
      erreur("Une erreur est survenue… Consultez le journal de bord.")
    end
  end #/ add

end #/Watchers
