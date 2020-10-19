# encoding: UTF-8
# frozen_string_literal: true
=begin
  Commande pour le concours annuel de synopsis.
=end
require_relative './concours/required'
class IcareCLI
class << self

  def proceed_concours
    # Quel check est à faire ?
    what = params[1]
    what_not_defined = what === nil
    if what
      begin
        require_relative "concours/commands/#{what}"
      rescue Exception => e
        puts "Sous-commande '#{what}' inconnue (jouer #{'icare concours help'.jaune} pour obtenir de l'aide)."
      end
      begin
        Concours.send(what.to_sym)
      rescue Exception => e
        puts "#{e.message}".rouge
        puts "#{e.backtrace.join("\n")}".rouge
      end
    end
  end #/ proceed_concours
end # /<< self
end #/IcareCLI
