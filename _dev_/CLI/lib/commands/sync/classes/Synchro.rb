# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self

def check_if_synchronization_required
  nombre_update_required = OPERATIONS[:updates].count
  if nombre_update_required > 0
    puts "\n\nNombre d'actualisations requises : #{nombre_update_required}".rouge
  end
  nombre_deletion_required = OPERATIONS[:deletes].count
  if nombre_deletion_required > 0
    puts "\n\nNombre de destructions requises : #{nombre_deletion_required}".rouge
  end
  OPERATIONS.merge!(synchro_required: (nombre_update_required+nombre_deletion_required > 0))
end #/ check_if_synchronization_required

def proceed_synchronisation
  # S'il y a l'option --sync, on doit passer directement à la synchronisation
  # Sinon, on demande quoi faire
  # S'il ne faut pas synchroniser, on enregistre le résultat pour une
  # utilisation ultérieure
  if IcareCLI.options[:sync] || proceder_a_la_synchro?
    require_relative './Synchro'
    synchronize(OPERATIONS)
    puts "#{RC*2}(Penser à lancer la commande 'icare test' pour voir si le site n'a pas été cassé.)"
  else
    memorise_synchronisation(OPERATIONS)
  end

end #/ proceed_synchronisation

# Opération principale de synchronisation.
# +operations+ Table contenant les synchronisations à faire :
#   :updates    Liste de SFile à synchroniser
#   :deletes    Liste des fichiers distants à supprimer
def synchronize(operations)
  puts "*** Synchronisation ***".bleu
  operations[:updates].each do |sfile|
    sfile.synchronize
  end
  operations[:deletes].each do |df|
    puts "Pour le moment, je ne détruis pas #{df.inspect}"
  end
end #/ synchronise

end # / << self
end # / IcareCLI
