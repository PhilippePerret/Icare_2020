# encoding: UTF-8
class Watcher < ContainerClass
  def valid_mail
    message "Je dois jouer le processus User/valid_mail"
  end # / valid_mail
  def contre_valid_mail
    message "Je dois jouer le contre processus User/contre_valid_mail"
  end # / contre_valid_mail
  def resend_valid_mail
    message "Je dois renvoyer le mail de validation de l'adresse mail"
  end #/ resend_valid_mail
end #/Watcher < ContainerClass
