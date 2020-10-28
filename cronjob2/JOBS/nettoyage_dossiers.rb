# encoding: UTF-8
# frozen_string_literal: true
class Cronjob

  def data
    @data ||= {
      name:       "Nettoyage des dossiers",
      frequency:  {day:6, hour:2},
    }
  end #/ data

  def nettoyage_dossiers
    runnable? || return

    return true
  end #/ nettoyage_dossiers

end #/Cronjob
