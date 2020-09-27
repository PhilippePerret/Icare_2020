# encoding: UTF-8
# frozen_string_literal: true

module HelpersWritingMethods

  # ---------------------------------------------------------------------
  #
  #   Méthodes d'helpers
  #
  # ---------------------------------------------------------------------

  # Pour marquer ou comptabiliser un résultat, un check
  def result(ok, key_message, extras = nil)
    data_check = RESULTATS[key_message]
    if ok
      # Success
      puts "#{TABU}#{data_check[:success]}".vert if IcareCLI.verbose?
    else
      # Failure
      msg = [data_check[:failure]]
      if data_check.key?(:reparer)
        msg << "Réparation possible : #{data_check[:reparer] % extras}"
      end
      if data_check.key?(:request)
        if IcareCLI.reparer?
          request = data_check[:request] % extras
          db_exec(request)
          puts "#{TABU}Réparé avec : #{request}".bleu
        else
          msg << "Requête online : #{data_check[:request] % extras}"
        end
      end
      raise(DataCheckedError.new(msg.join(RC), extras))
    end
    return ok # plus vraiment utile maintenant
  end #/ result

  def mark_success
    puts "#{IcareCLI.verbose? ? TABU : "\r"}√ #{la_chose.titleize} ##{id} est OK".vert
  end #/ mark_success
  def mark_failure
    puts "#{IcareCLI.verbose? ? TABU : "\r"}# Problème avec #{la_chose.titleize} ##{id}".rouge
  end #/ mark_failure

  # ---------------------------------------------------------------------
  #
  #   Méthode de check communes
  #
  # ---------------------------------------------------------------------

  def user_id_defined
    result(not(user_id.nil?), :owner_required)
  end #/ user_id_defined

  def owner_exists
    result(User.exists?(user_id), :owner_exists, {user_id:user_id, id:id})
  end #/ owner_exists

  # ---------------------------------------------------------------------
  #
  #   Méthodes de données
  #
  # ---------------------------------------------------------------------

  # Retourne le propriétaire de la chose (de l'icmodule, du document, etc.)
  def owner
    @owner ||= begin
      unless user_id.nil?
        usr = User.get(user_id)
        usr = nil if usr.data.nil?
        usr
      end
    end
  end #/ owner
end #/HelpersWritingMethods
