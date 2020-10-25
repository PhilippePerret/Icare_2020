# encoding: UTF-8
# frozen_string_literal: true
class ConcoursStep
class Operation
  def send_mail_icariens_annonce_start(options)
    request = "SELECT mail, pseudo, sexe FROM users WHERE id <> 9 AND SUBSTRING(options,4,1) <> 1"
    MailSender.send(db_exec(request), 'annonce_start_icariens', options)
  end
  def send_mail_concurrents_annonce_start(options)
    request = "SELECT patronyme AS pseudo, mail, sexe FROM #{DBTBL_CONCURRENTS}"
    MailSender.send(db_exec(request), 'annonce_start_concurrents', options)
  end

  def send_mail_jury_annonce_start(options)
    MailSender.send(Concours.current.jury_members, 'annonce_start_jury', options)
  end

end
end #/Concours
