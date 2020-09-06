# encoding: UTF-8
# frozen_string_literal: true

require_module('form')

class HTML
  def titre
    "Oubli du mot de passe"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id) == 'form-password-forgotten'.freeze
      form = Form.new
      traite_mot_de_passe_oublied if form.conform?
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb(STRINGS[:body], self)
  end # /build_body


  # Méthode qui procède à la création du nouveau mot de passe
  # et son envoi à l'adresse voulue (si elle est valide)
  def traite_mot_de_passe_oublied
    # On vérifie que l'adresse mail est une adresse mail connu.
    adresse_valide? || begin
      erreur(ERRORS[:mail_valide_required])
      return
    end
    require_module('mail')
    user_mail = param(:user_mail)
    usr = User.get_by_mail(user_mail)
    # On trouve un nouveau mot de passe et on le crypte
    prov_password = "#{rand(900)+100}-#{rand(900)+100}-#{rand(900)+100}"
    prov_salt = "#{rand(90)+10}-#{rand(90)+10}"
    crypted_password = User.encrypte_password(prov_password,usr.mail,prov_salt)
    # On enregistre le nouveau mot de passe
    db_compose_update('users', usr.id, {cpassword:crypted_password, salt:prov_salt})
    # On envoie le message de nouveau mot de passe
    usr.send_mail({
      subject: MESSAGES[:sujet_mail_envoi_password],
      message: (MESSAGES[:message_mail_envoi_password] % {pseudo: usr.pseudo, password: prov_password})
    })
    message(MESSAGES[:mot_de_passe_sent] % user_mail)
  end #/ traite_mot_de_passe_oublied


  def adresse_valide?
    db_count('users', {mail: param(:user_mail)}) == 1
  end #/ adresse_valide?

end #/HTML
