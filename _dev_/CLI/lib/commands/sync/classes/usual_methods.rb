# encoding: UTF-8
# frozen_string_literal: true

def proceder_a_la_synchro?(de_what = nil)
  Q.yes?("Dois-je procéder à la synchronisation#{" #{de_what}" if de_what} ?")
end #/ proceder_a_la_synchro?

# Méthode pour mémoriser les résultats de cette analyse de synchro
def memorise_synchronisation(operations)
  File.open(OPERATIONS_PATH,'wb') { |f| f.write Marshal.dump(operations) }
  puts <<-TEXT.bleu

J'ai mémorisé les synchronisations requises.
Il te suffit de jouer la commande suivante pour
les lancer :

  #{'icare sync --sync'.jaune}

  TEXT
end #/ memorise_synchronisation


# Méthode appelée pour recharger le fichier OPERATIONS_PATH qui contient les
# données des dernières opérations à faire mais pas exécutées
def reload_operations
  old_data = File.open(OPERATIONS_PATH,'rb') { |f| Marshal.load(f) }
  OPERATIONS.merge!(old_data)
end #/ reload_operations
