# encoding: UTF-8
class User

  DATA_GUEST = {
    'id':       0,
    'pseudo':   'Invité',
    'mail':     'johndoe@gmail.com',
    'options':  '00109000000000001109000900000000'
  }

  # Retourne le nombre de notifications non vues
  def unread_notifications_count
    return 0 if user.guest?
    where = if user.admin?
              "vu_admin = FALSE"
            else
              "user_id = #{id} AND vu_user = FALSE"
            end
    where << " AND ( triggered_at IS NULL OR triggered_at < #{Time.now.to_i})".freeze
    return db_count('watchers', where)
  end #/ unread_notifications_count

end #/User
