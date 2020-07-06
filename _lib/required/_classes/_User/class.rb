# encoding: UTF-8
=begin
  Module général User
  -------------------
  On ne doit mettre ici que les méthodes générales qui servent partout
=end
class User

class << self
  attr_accessor :current

  def table
    @table ||= 'users'.freeze
  end #/ table

  # Initialisation de l'utilisateur courant
  # Soit c'est l'utilisateur reconnu par la session, soit c'est un invité
  def init
    log("session['user_id'] = #{session['user_id'].inspect}".freeze)
    reconnect_user unless session['user_id'].nil_if_empty.nil?
    self.current ||= User.instantiate(DATA_GUEST)
  end

  # Reconnection d'un icarien reconnu en session
  def reconnect_user
    duser = db_get('users', {id: session['user_id'].to_i})
    duser || raise(ERRORS[:unfound_user_with_id] % [session['user_id']])
    duser[:session_id] == session.id || raise(ERRORS[:alert_intrusion])
    self.current = self.get(duser[:id])
    log "USER RECONNECTED : #{current.pseudo} (##{current.id})".freeze
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
