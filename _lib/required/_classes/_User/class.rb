# encoding: UTF-8
=begin
  Module général User
  -------------------
  On ne doit mettre ici que les méthodes générales qui servent partout
=end
class User

REQUEST_USER = <<-SQL
SELECT u.id, u.pseudo, u.mail, u.sexe, u.options, u.icmodule_id
  FROM users u
  WHERE u.id = %{id}
SQL

class << self
  attr_accessor :current

  def get(uid)
    uid = uid.to_i
    @items ||= {}
    @items[uid] ||= get_in_db(uid)
  end #/ get


  def get_in_db(id)
    duser = db_exec(REQUEST_USER % {id: id})[0]
    new(duser) unless duser.nil?
  end #/ get_in_db

  # Initialisation de l'utilisateur courant
  # Soit c'est l'utilisateur reconnu par la session, soit c'est un invité
  def init
    log('-> User::init'.freeze)
    log("session['user_id'] = #{session['user_id'].inspect}")
    reconnect_user unless session['user_id'].nil_if_empty.nil?
    self.current ||= new(DATA_GUEST)
    # debug "OFFLINE: #{OFFLINE ? 'oui' : 'non'}"
  end

  # Reconnection d'un icarien reconnu en session
  def reconnect_user
    log('-> reconnect_user'.freeze)
    log "session['user_id']: #{session['user_id'].inspect}".freeze
    duser = db_get('users', {id: session['user_id'].to_i})
    duser || raise("Impossible de trouver un utilisateur d'identifiant #{session['user_id']}…")
    duser[:session_id] == session.id || raise("Ceci ressemble à une intrusion en force. Je ne peux pas vous laisser passer…")
    self.current = new(duser)
    log "User reconnecté : #{current.pseudo}"
  rescue Exception => e
    erreur e.message
    session.delete('user_id') # pour ne plus avoir le problème
  end

  # Retourne le mot de passe encrypté à partir du mot de passe en clair,
  # du mail et du sel fournis.
  def encrypte_password(pwd,email,salt)
    require 'digest/md5'
    Digest::MD5.hexdigest("#{pwd}#{email}#{salt}")
  end

end #/<<self
end #/User
