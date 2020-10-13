# encoding: UTF-8
# frozen_string_literal: true
=begin
  Les méthodes qui sont appelées par les modules du site mais n'ont
  pas de correspondances
=end

def erreur(err)
  log("# ERREURS : #{err.inspect}")
end #/ erreur
