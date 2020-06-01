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
  end #/ add

  # Nombre de watchers non vus
  def non_vus_count
    @non_vus_count ||= all.reject{|w|w.vu?}.count
  end #/ non_vus_count

end #/Watchers
