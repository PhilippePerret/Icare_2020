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
  # Cette méthode est appelée par App.init après le chargement des modules
  # requis.
  # Soit c'est l'utilisateur reconnu par la session, soit c'est un invité
  # On peut aussi avoir une identification automatique d'un user quelconque,
  # utilisée pour les tests des liens (par CURL). Cf. le mode d'emploi ou
  # la méthode connect_any_user
  def init
    log("-> User::init")
    connect_any_user || begin
      # log("session['user_id'] = #{session['user_id'].inspect}")
      reconnect_user unless session['user_id'].nil_if_empty.nil?
    end
    self.current ||= User.instantiate(DATA_GUEST)
  end

  # Connexion pour usage par CURL. La requête http définit le paramètre
  # curluser qui définit un nom de fichier contenu dans le dossier tmp
  # qui contient l'identifiant de l'user à connecter. Ensuite, tout doit
  # se faire par session
  def connect_any_user
    return false if param(:curluser).nil?
    # Le fichier qui doit exister et définir l'identifiant de l'user à
    # connecter (note : en général, c'est un faux user, juste pour les tests)
    pth = File.join(TEMP_FOLDER, param(:curluser))
    # On doit empêcher une utilisation frauduleuse
    return false unless File.exists?(pth)
    # Tout est bon, on va recharger l'user
    login_user(File.read(pth).to_i)
    # C'est un fichier à usage unique
    File.delete(pth)
    # Pour empêcher de tester une autre méthode de connexion
    return true
  end #/ connect_any_user

  def init_as_admin
    log("-> User::init_as_admin")
    # Dans tous les cas on charge la boite à outils
    require_module('admin/toolbox')
    # Si une opération administrateur est demandée
    if param(:adminop)
      require_module('admin/operations')
      Admin.operation(param(:adminop).to_sym)
    end
  end #/ init_as_admin

  # Pour identifier l'user la première fois
  # On met son ID dans la variable 'user_id' en session
  # On met sa session dans sa table
  # @Return l'instance {User} de l'utilisateur loggué
  def login_user(uid)
    session['user_id'] = uid.to_s
    db_compose_update('users', uid, {session_id: session.id})
    # db_exec("UPDATE users SET session_id = ? WHERE id = ?", [session.id, uid])

    self.current = self.get(uid)
    # Si l'utilisateur est un administrateur, on le traite tel quel
    init_as_admin if current.admin?
  end #/ login_user

  # Reconnection d'un icarien reconnu en session
  def reconnect_user
    duser = db_get('users', {id: session['user_id'].to_i})
    duser || raise(ERRORS[:unfound_user_with_id] % [session['user_id']])
    duser[:session_id] == session.id || raise(ERRORS[:alert_intrusion])
    self.current = self.get(duser[:id])
    log "USER RECONNECTED : #{current.pseudo} (##{current.id})"
    # Si l'utilisateur est un administrateur, on le traite tel quel
    init_as_admin if current.admin?
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
