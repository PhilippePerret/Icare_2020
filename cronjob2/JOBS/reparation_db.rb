# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce module vise à "réparer" la table `users` pour qu'elle soit toujours
  correcte.
=end
require_relative './reparation_db/_required'

class Cronjob

  def data
    @data ||= {
      name:       "Réparation de la base de données",
      frequency:  {hour:4},
    }
  end #/ data

  def reparation_db
    proceed_reparations
    return true
  end

  def proceed_reparations
    reparation_users
  end #/ proceed_reparations

end #/Cronjob
