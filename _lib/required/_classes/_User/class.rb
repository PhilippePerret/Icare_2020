# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module général User
  -------------------
  On ne doit mettre ici que les méthodes générales qui servent partout
=end
class User

class << self
  attr_accessor :current

  def table
    @table ||= 'users'
  end #/ table

  def get_by_pseudo(pseudo)
    res = db_exec("SELECT id FROM users WHERE pseudo = ?", [pseudo]).first
    res.nil? ? nil : self.get(res[:id])
  end #/ get_by_pseudo
  def get_by_mail(umail)
    res = db_exec("SELECT id FROM users WHERE mail = ?", [umail]).first
    res.nil? ? nil : self.get(res[:id])
  end #/ get_by_mail

  # Initialisation de l'utilisateur courant
  # Soit c'est l'utilisateur reconnu par la session, soit c'est un invité
  def init
    log("session['user_id'] = #{session['user_id'].inspect}")
    reconnect_user unless session['user_id'].nil_if_empty.nil?
    self.current ||= User.instantiate(DATA_GUEST)
    # Si l'utilisateur est un administrateur, on le traite tel quel
    init_as_admin if user.admin?
  end

  def init_as_admin
    # Dans tous les cas on charge la boite à outils
    require_module('admin/toolbox')
    # Si une opération administrateur est demandée
    if param(:adminop)
      require_module('admin/operations')
      Admin.operation(param(:adminop).to_sym)
    end
  end #/ init_as_admin

  # Reconnection d'un icarien reconnu en session
  def reconnect_user
    duser = db_get('users', {id: session['user_id'].to_i})
    duser || raise(ERRORS[:unfound_user_with_id] % [session['user_id']])
    duser[:session_id] == session.id || raise(ERRORS[:alert_intrusion])
    self.current = self.get(duser[:id])
    log "USER RECONNECTED : #{current.pseudo} (##{current.id})"
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
