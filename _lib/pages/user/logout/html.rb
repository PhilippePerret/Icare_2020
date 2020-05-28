# encoding: UTF-8
class HTML
  def exec
    @user_init = user
    user.deconnecte
  end
  def build_body
    @body = deserb('body', @user_init)
  end
end

class User
  # On procède à la déconnexion de l'user
  def deconnecte
    session['user_id'] = nil
    session.delete('user_id')
    ndata = {session_id: 'NULL'}
    user.set(ndata)
    set_last_connexion(user)
    User.current = User.new(DATA_GUEST)
  end

  def set_last_connexion(user)
    request = if last_connexion_for?(user)
      debug("Dernière connexion: #{db_get('connexions',{id:user.id}).inspect}")
                "UPDATE connexions SET route = ?, time = ? WHERE id = ?"
              else
                "INSERT connexions (route, time, id) VALUES (?, ?, ?)"
              end
    values  = [Route.last, Time.now.to_i, user.id]
    db_exec(request, values)
  end

  def last_connexion_for?(user)
    db_count('connexions', {id: user.id}) > 0
  end

end
