# encoding: UTF-8
# frozen_string_literal: true

module HelpersWritingMethods

  # ---------------------------------------------------------------------
  #
  #   Méthodes d'helpers
  #
  # ---------------------------------------------------------------------

  # Pour marquer ou comptabiliser un résultat, un check
  def result(ok, msg_success)
    puts "#{TABU}#{msg_success}".vert if IcareCLI.verbose? && ok
    return ok
  end #/ result

  def mark_success
    puts "#{IcareCLI.verbose? ? TABU : "\r"}√ #{la_chose.titleize} ##{id} est OK".vert
  end #/ mark_success
  def mark_failure
    puts "#{IcareCLI.verbose? ? TABU : "\r"}? #{la_chose.titleize} ##{id} est défectueux".rouge
  end #/ mark_failure

  # ---------------------------------------------------------------------
  #
  #   Méthodes de données
  #
  # ---------------------------------------------------------------------

  # Retourne le propriétaire de la chose (de l'icmodule, du document, etc.)
  def owner
    @owner ||= User.get(user_id)
  end #/ owner
end #/HelpersWritingMethods
