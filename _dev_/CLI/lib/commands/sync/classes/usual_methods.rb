# encoding: UTF-8
# frozen_string_literal: true

def proceder_a_la_synchro?(de_what = nil)
  Q.yes?("Dois-je procéder à la synchronisation#{" #{de_what}" if de_what} ?")
end #/ proceder_a_la_synchro?

# Méthode pour mémoriser les résultats de cette analyse de synchro
def memorise_synchronisation(operations)

end #/ memorise_synchronisation
