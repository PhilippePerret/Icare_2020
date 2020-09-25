# encoding: UTF-8
# frozen_string_literal: true
=begin
  Extension de User pour la création d'un nouvel icarien
=end
require_module('mail')
class User
# Envoi du mail de validation de l'adresse mail
attr_reader :ticket_validation_mail

def send_mail_validation_mail(params)
  require_module('ticket')
  @ticket_validation_mail = Ticket.create({user_id:id, code:"run_watcher(#{params[:watcher_id]})"})
  body = deserb('mail_pour_validation_mail', self)
  Mail.send(to:mail, subject:'Validation du mail', message:body)
end #/ send_mail_validation_mail

def send_mail_confirmation_inscription
  body = deserb('confirmation_inscription', self)
  Mail.send(to:mail, subject:'Confirmation de votre candidature', message:body)
end #/ send_mail_confirmation_inscription

end #/User
