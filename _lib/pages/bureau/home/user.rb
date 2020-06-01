# encoding: UTF-8
class User
  # Retourne le nombre de notifications pas encore vues
  def pastille_notifications_non_vues
    Tag.pastille_nombre(watchers.non_vus_count)
  end

  def pastille_messages_frigo_non_vus
    count = 7 # TODO
    Tag.pastille_nombre(count)
  end

end #/User
