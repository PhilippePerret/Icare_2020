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
    what = params[1]
    what = nil if not(File.exists?(File.join(__dir__,'check',"#{what}.rb")))
    what ||= begin
      Q.select(MESSAGES[:question_read], required: true) do |q|
        q.choices DATA_WHAT_CHECK
        q.per_page DATA_WHAT_CHECK.count
      end
    end
    require_relative "./check/#{what}"
    send("proceed_check_#{what}".to_sym)
  end #/ proceed_check
end # /<< self
end #/IcareCLI
