# encoding: UTF-8
# frozen_string_literal: true
=begin
  Commande pour procéder à différents checks.
  Chaque type de check possède son module dans le dossier ./check de ce
  dossier.
=end
require_relative './check/xlib/required'

class IcareCLI
class << self
  def proceed_check
    # Quel check est à faire ?
    what = params[1]
    what = what[0...-1] if what.end_with?('s')
    what = nil if not(respond_to?("proceed_check_#{what}".to_sym))
    what ||= begin
      Q.select(MESSAGES[:question_read], required: true) do |q|
        q.choices DATA_WHAT_CHECK
        q.per_page DATA_WHAT_CHECK.count
      end
    end
    return if what == :cancel

    # Le check de qui/quoi est à faire
    who  = params[2]
    who = who.to_i unless who.nil?

    # On procède au test
    CheckCase.init
    if what.to_sym == :etape
      puts "Le check des documents devrait être lancé avant le check des étapes.".jaune
    end
    send("proceed_check_#{what}".to_sym, who)
    CheckCase.report

  end #/ proceed_check

  def proceed_check_all
    proceed_check_user(nil)
    proceed_check_document(nil)
    proceed_check_module(nil)
    proceed_check_etape(nil)
  end #/ proceed_check_all

  def proceed_check_user(who)
    CheckedUser.check(who) # seulement who ou tous si who == nil
  end #/ proceed_check_user

  def proceed_check_module(who)
    CheckedModule.check(who)
  end #/ proceed_check_module

  def proceed_check_etape(who)
    CheckedEtape.check(who)
  end #/ proceed_check_etape

  def proceed_check_document(who)
    CheckedDocument.check(who)
  end #/ proceed_check_document

  # ---------------------------------------------------------------------
  #
  #   Options
  #
  # ---------------------------------------------------------------------

end # /<< self
end #/IcareCLI
