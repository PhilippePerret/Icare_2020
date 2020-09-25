# encoding: UTF-8
# frozen_string_literal: true
class Watcher < ContainerClass
  def valid_mail
    user.valide_mail
  end # / valid_mail

  # Méthode appelée pour envoyer à nouveau le message de demande de
  # confirmation de l'adresse mail.
  def resend_valid_mail
    message "Je dois renvoyer le mail de validation de l'adresse mail"
  end #/ resend_valid_mail
end #/Watcher < ContainerClass

class User
  def valide_mail
    set_option(2,1,{save:true})
    message("Votre mail a été confirmé, merci à vous.")
  end #/ valide_mail
end #/User
