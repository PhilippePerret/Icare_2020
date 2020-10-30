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
    runnable? || return
    require_relative './mails_concours/required'
    Concurrent.send_mail_info_hebdomadaire
    return true
  end #/

end #/Cronjob
