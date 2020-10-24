# encoding: UTF-8
# frozen_string_literal: true
class ConcoursStep
class Operation
  def send_mail_icariens_annonce_start(options)
    html.res << "📤 Envoi de l'annonce du démarrage à tous les icariens"
    request = "SELECT mail, pseudo FROM users WHERE id <> 9 AND SUBSTRING(options,4,1) <> 1"
    MailSend.send(db_exec(request), 'annonce_start_icariens', options)
  end #/ send_mail_icariens_annonce_start
  def send_mail_concurrents_annonce_start(options)
    html.res << "📤 Envoi de l'annonce du démarrage aux concurrents"

  end #/ send_mail_concurrents_annonce_start

  def send_mail_jury_annonce_start(options)
    html.res << "📤 Envoi de l'annonce du démarrage aux membres du jury"

  end #/ send_mail_jury_annonce_start

end
end #/Concours
