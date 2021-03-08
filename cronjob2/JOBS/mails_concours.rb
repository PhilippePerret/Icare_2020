# encoding: UTF-8
# frozen_string_literal: true
=begin
  Tout ce qui concerne le CONCOURS DE SCÉNARIO
=end
class Cronjob

  def data
    @data ||= {
      name: "Traitement du Concours de Scénario",
      frequency: {hour:11, day:6} # seulement le samedi
    }
  end #/ data

  def mails_concours
    require_relative './mails_concours/required'
    # Ne rien faire si le concours en est à sa phase 3
    # Rappel : phase 1 = dépôt des projets, phase 2 = présélection des 10
    # finaliste, phase 3 = sélection des 3 lauréats, phase 5 = fin officielle
    # du concours
    return if Concours.current.phase > 3
    Concurrent.send_mail_info_hebdomadaire
    return true
  end #/

end #/Cronjob
