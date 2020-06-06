# encoding: UTF-8
class Watcher < ContainerClass
  def valid_mail
    user.valide_mail
    # Noter que le watcher sera automatiquement détruit
  end # / valid_mail

  # Méthode appelée pour envoyer à nouveau le message de demande de
  # confirmation de l'adresse mail.
  def resend_valid_mail
    message "Je dois renvoyer le mail de validation de l'adresse mail"
  end #/ resend_valid_mail
end #/Watcher < ContainerClass

class User
  def valide_mail
    set_option(2,1)
    message("Votre mail a été confirmé, merci à vous.".freeze)
  end #/ valide_mail
end #/User
