# encoding: UTF-8
# frozen_string_literal: true
class ConcoursStep
class Operation
  def send_mail_concurrents_annonce_start
    concours.res << "📤 Envoi de l'annonce du démarrage aux concurrents"
  end #/ send_mail_concurrents_annonce_start

  def send_mail_jury_annonce_start
    concours.res << "📤 Envoi de l'annonce du démarrage aux membres du jury"
  end #/ send_mail_jury_annonce_start
  
end
end #/Concours
