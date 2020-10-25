# encoding: UTF-8
# frozen_string_literal: true
class ConcoursStep
class Operation
  def send_mail_icariens_annonce_start(options)
    html.res << "📤 Envoi de l'annonce du démarrage à tous les icariens"
    request = "SELECT mail, pseudo, sexe FROM users WHERE id <> 9 AND SUBSTRING(options,4,1) <> 1"
    MailSender.send(db_exec(request), 'annonce_start_icariens', options)
  end #/ send_mail_icariens_annonce_start
  def send_mail_concurrents_annonce_start(options)
    html.res << "📤 Envoi de l'annonce du démarrage aux concurrents"
    request = "SELECT patronyme AS pseudo, mail FROM #{DBTBL_CONCURRENTS}"
    MailSender.send(db_exec(request), 'annonce_start_concurrents', options)
  end #/ send_mail_concurrents_annonce_start

  def send_mail_jury_annonce_start(options)
    html.res << "📤 Envoi de l'annonce du démarrage aux membres du jury"
    MailSender.send(Concours.current.jury_members, 'annonce_start_jury', options)
  end #/ send_mail_jury_annonce_start

end
end #/Concours
