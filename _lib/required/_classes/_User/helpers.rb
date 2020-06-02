# encoding: UTF-8
=begin
  Module User pour les helpers methods
=end
class User
  # Retourne le visage de l'utilisateur, en fonction du fait que c'est
  # un homme ou une femme
  def visage
    @face ||= (femme? ? '👩‍🎓' : '👨‍🎓').freeze
  end #/ face

  # Retourne la pastille contenant les notifications non vues
  # Noter qu'ici la méthode est accessible partout sans charger
  # le module 'watchers'
  def pastille_notifications_non_vues
    return '' unless user.icarien?
    nombre = unread_notifications_count
    return '' if nombre == 0
    Tag.pastille_nombre(nombre,{linked:true})
  end
  def unread_notifications_count
    where = if user.admin?
              "vu_admin = FALSE"
            else
              "user_id = #{id} AND vu_user = FALSE"
            end
    # request = "SELECT COUNT(id) FROM watchers WHERE #{where}"
    db_count('watchers', where)
  end #/ unread_notifications_count

end #/User
