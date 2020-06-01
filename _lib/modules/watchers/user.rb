# encoding: UTF-8
=begin
  Extension de User pour les watchers
=end
class User
def watchers
  @watchers ||= UserWatchers.new(self)
end #/ watchers
end #/User

# ---------------------------------------------------------------------
#
#   class UserWatchers
#
# ---------------------------------------------------------------------

class UserWatchers
  attr_reader :owner
  def initialize owner
    @owner = owner
  end #/ initialize

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

  # Nombre de watchers non vus
  def non_vus_count
    @non_vus_count ||= all.reject{|w|w.vu?}.count
  end #/ non_vus_count

end #/Watchers
