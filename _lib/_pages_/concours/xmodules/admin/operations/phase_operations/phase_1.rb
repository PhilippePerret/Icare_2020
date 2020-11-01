# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
class ConcoursPhase
class Operation
  def send_mail_icariens_annonce_start(options)
    request = "SELECT mail, pseudo, sexe FROM users WHERE id <> 9 AND SUBSTRING(options,4,1) <> 1"
    MailSender.send_mailing({to:db_exec(request), file:mail_path('phase1/annonce_start_icariens'), bind:self}, options)
  end

  def send_mail_concurrents_annonce_start(options)
    request = "SELECT patronyme AS pseudo, mail, sexe FROM #{DBTBL_CONCURRENTS}"
    MailSender.send_mailing({to:db_exec(request), file:mail_path('phase1/annonce_start_concurrents'), bind:self}, options)
  end

  def send_mail_jury_annonce_start(options)
    MailSender.send_mailing({to:Concours.current.jury_members, file:mail_path('phase1/annonce_start_jury'), bind:self}, options)
  end

  def add_actualite_concours_start(options)
    msg = "LANCEMENT DE LA SESSION #{Concours.current.annee} DU CONCOURS DE SYNOPSIS."
    if options[:noop]
      html.res << "<div class='ml2'>Message : #{msg}</div>"
    else
      Actualite.add("CONCSTART", 1, msg)
    end
  end #/ add_actualite_concours_start
end
end #/Concours
