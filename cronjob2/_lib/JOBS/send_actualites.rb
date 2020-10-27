# encoding: UTF-8
# frozen_string_literal: true
class Cronjob

  def data
    @data ||= {
      name: "Envoi des actualités",
      frequency: {hour: 3}
    }
  end #/ data

  def send_actualites
    runnable? || return


    return true
  end #/ send_actualites
  
end #/Cronjob
