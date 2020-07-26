# encoding: UTF-8
require 'digest/md5'
require_module('form')
class HTML
  def titre
    "#{Emoji.get('objets/cadenas-stylo').page_title+ISPACE}Changement du mot de passe".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    if param(:form_id) == 'form-change-password'.freeze
      form = Form.new
      traitement_changement_password if form.conform?
    end
  end
  def build_body
    # Construction du body
    @body = deserb('body',self)
  end

  # Traitement proprement dit du changement de mot de passe
  # On regarde d'abord s'il est valide puis on fait toutes
  # les démarches nécessaires.
  def traitement_changement_password
    # Le courant doit être fourni
    cur_pass || raise(ERRORS[:oldpass_required])
    # Le courant doit être valide
    cur_pass_valide? || raise(ERRORS[:oldpass_invalide])
    # Le nouveau doit être fourni
    new_pass || raise(ERRORS[:newpass_required])
    # Le nouveau doit être valide
    new_pass_valide? || raise(ERRORS[:newpass_invalide] % @new_pass_invalidity)
    # On peut enregistrer le nouveau mot de passe
    require_module('user/utils')
    user.password = new_pass
  rescue Exception => e
    erreur(e.message)
  end #/ traitement_changement_password

  def cur_pass
    @current_pass ||= param(:old_password).nil_if_empty
  end #/ current_pass
  def new_pass
    @new_pass ||= param(:new_password).nil_if_empty
  end #/ new_pass

  # Retourne TRUE si le mot de passe courant fourni est valide
  def cur_pass_valide?
    cur_pass_encrypted = encrypte(cur_pass, user.mail, user.salt)
    unless cur_pass_encrypted === user.cpassword
      param('old_password', :null)
    end
    cur_pass_encrypted === user.cpassword
  end #/ cur_pass_valide?

  def new_pass_valide?
    new_pass.length > 6   || raise(ERRORS[:password_too_short])
    new_pass.length < 51  || raise(ERRORS[:password_too_long])
    reste = new_pass.gsub(/[a-zA-Z0-9\,\.\!\?\;\:…]/,'')
    reste == ''           || raise(ERRORS[:password_invalid])
    return true
  rescue Exception => e
    param('new_password', :null)
    @new_pass_invalidity = e.message.downcase
    return false
  end #/ new_pass_valide?

  def encrypte(pwd, mail, salt)
    Digest::MD5.hexdigest("#{pwd}#{mail}#{salt}")
  end #/ cpassword

end #/HTML
