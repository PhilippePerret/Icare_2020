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
      Logger << "C'est un test sans opération (noop)."
    else
      Logger << "C'est un test avec opération"
    end
    Logger << "ENV['ONLINE'] = #{ENV['ONLINE'].inspect}"
    Logger << "ONLINE  = #{ONLINE.inspect}"
    Logger << "DB_NAME = #{DB_NAME.inspect} (constante) #{MyDB.DBNAME.inspect} (db.rb)"
    Logger << "Tentative de relève de quelques users"
    request = "SELECT id, pseudo, mail FROM users WHERE id > 100 && id < 120"
    db_exec(request).each do |du|
      Logger << du.inspect
    end
  end #/ proceed_test
end #/Cronjob
