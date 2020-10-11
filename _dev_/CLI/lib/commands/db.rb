# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self
  def proceed_db
    require_relative 'db/required'
    puts "Pas encore implémenté"
    request = db_compose_insert('watchers', {user_id: 81, objet_id: 864, wtype: 'send_comments'})
    if Q.yes?("Exécuter la requête #{request.inspect} ? ")
      puts "ok"
    else
      puts "tant pis"
    end
    # eval(request)
  rescue Exception => e
    puts e.message.rouge + RC*2
  end #/ proceed_goto
end # /<< self
end #/IcareCLI
