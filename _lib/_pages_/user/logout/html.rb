# encoding: UTF-8
class HTML
  def exec
    @user_init = user
    user.deconnecte
  end
  def titre
    "#{Emoji.get('gestes/coucou-main').page_title+ISPACE}À bientôt".freeze
  end #/ titre
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
    User.current = User.instantiate(DATA_GUEST)
  end

  def set_last_connexion(user)
    return if user.guest? || Route.last.nil?
    request = if last_connexion_for?(user)
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
