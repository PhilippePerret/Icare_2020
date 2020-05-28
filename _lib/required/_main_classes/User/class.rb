# encoding: UTF-8
=begin
  Module général User
  -------------------
  On ne doit mettre ici que les méthodes générales qui servent partout
=end
class User
class << self
  attr_accessor :current

  # Initialisation de l'utilisateur courant
  # Soit c'est l'utilisateur reconnu par la session, soit c'est un invité
  def init
    unless session['user_id'].nil_if_empty.nil?
      reconnect_user
    end
    self.current ||= new(DATA_GUEST)
    # debug "OFFLINE: #{OFFLINE ? 'oui' : 'non'}"
  end

  # Reconnection d'un icarien reconnu en session
  def reconnect_user
    return if session['user_id'].nil_if_empty.nil?
    debug "session['user_id']: #{session['user_id'].inspect}"
    duser = db_get('users', {id: session['user_id'].to_i})
    duser || raise("Impossible de trouver un utilisateur d'identifiant #{session['user_id']}…")
    duser[:session_id] == session.id || raise("Ceci ressemble à une intrusion en force. Je ne peux pas vous laisser passer…")
    self.current = new(duser)
    debug "User reconnecté : #{current.pseudo}"
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
