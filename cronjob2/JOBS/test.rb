# encoding: UTF-8
# frozen_string_literal: true
class Cronjob

  def data
    @data ||= {
      name: "Un test pour tester le Cronjob",
      frequency: {hour:5}
    }
  end #/ data
  def test
    runnable? || return
    proceed_test
    return true
  end #/ test

  def proceed_test
    if Cronjob.noop?
      Logger << "Ceci est le test sans opération (noop)."
    else
      Logger << "Ceci est le test avec opération"
    end
  end #/ proceed_test
end #/Cronjob
