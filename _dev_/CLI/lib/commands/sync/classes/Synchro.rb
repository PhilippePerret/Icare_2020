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
  files_to_delete = []
  operations[:deletes].each do |df|
    k = Q.keypress("\n\nDois-je détruire le fichier distant “#{df['path'].jaune}” ? (return: Oui, space: Non, tab: Tout abandonner)", keys: [:return, :space, :tab])
    case k
    when "\t" then return
    when "\r" then files_to_delete << df['path']
    when " "  then next
    end
  end

  # S'il y a des fichiers à détruire, on les détruit.
  unless files_to_delete.empty?
    cmd = SSH_REQUEST_DELETE_FILES % {files: files_to_delete.inspect}
    # puts "Commande destruction : #{cmd}"
    res = `#{cmd} 2>&1`
    res = JSON.parse(res)
    if files_to_delete.count == res.count
      puts "Tous les fichiers choisis ont été correctement détruits.".vert
    else
      puts "Apparemment, tous les fichiers n'ont pas pu être détruit… (#{res.count} détruit(s) contre #{files_to_delete.count} attendu(s)).".rouge
      puts "Seuls les fichiers suivants ont pu être détruits :\n- #{res.join("\n- ")}".rouge
    end
  end

end #/ synchronise

end # / << self
end # / IcareCLI
