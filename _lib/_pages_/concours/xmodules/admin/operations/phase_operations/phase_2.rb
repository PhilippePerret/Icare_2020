# encoding: UTF-8
# frozen_string_literal: true
require_module('mail')
class ConcoursPhase
class Operation
  def add_actualite_concours_echeance(options)
    Actualite.create(type:'CONCECHE', message:"La session #{ANNEE_CONCOURS_COURANTE} du Concours de Synopsis est arrivée à échéance. Préselection en cours.")
  end

  def send_mail_concurrents_echeance(options)
    request = <<-SQL
SELECT
  cc.patronyme AS pseudo, cc.mail, cc.sexe, cpc.annee, cpc.specs
  FROM #{DBTBL_CONCURRENTS} cc
  INNER JOIN #{DBTBL_CONCURS_PER_CONCOURS} cpc ON cpc.concurrent_id = cc.concurrent_id
  WHERE cpc.annee = ?
    SQL

    # On doit séparer les concurrents qui ont un fichier conforme des autres,
    # pour leur envoyer deux mails différents. Se souvenir que le principe,
    # pour les mailings, c'est de charger une bonne fois pour toute le message
    # déserbé, puis de remplacer seulement les variables %{...} qui ici se
    # limitent au pseudo.
    destinataires_file_ok = []
    destinataires_file_notok = []
    db_exec(request, [ANNEE_CONCOURS_COURANTE]).each do |dc|
      if dc[:specs][0..1] == "11"
        destinataires_file_ok << dc
      else
        destinataires_file_notok << dc
      end
    end
    # On peut faire le mailing des deux mails
    MailSender.send_mailing({from:CONCOURS_MAIL, to:destinataires_file_ok, file:mail_path('phase2/mail_fin_echeance_file_ok'), bind:self}, options)
    MailSender.send_mailing({from:CONCOURS_MAIL, to:destinataires_file_notok, file:mail_path('phase2/mail_fin_echeance_file_notok'), bind:self}, options)
  end #/ send_mail_concurrents_echeance

  def send_mail_jury_echeance(options)
    MailSender.send_mailing({from:CONCOURS_MAIL, to:Concours.current.jury, file:mail_path('phase2/mail_fin_echeance_jury'), bind:self}, options)
  end #/ send_mail_jury_echeance

  # Méthode qui s'assure que toutes les conformités sont bien réglées
  # pour chaque fichier de candidature déposé
  def check_reglage_conformite(options)
    # TODO
  end #/ check_reglage_conformite
end
end #/Concours
