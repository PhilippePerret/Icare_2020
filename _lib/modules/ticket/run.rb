# encoding: UTF-8
# frozen_string_literal: true
=begin

  Extension de la class Ticket
  Les deux méthods :run, pour la classe et pour l'instance

=end
class Ticket
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

  # Joue le ticket défini dans l'URL
  #
  # IN    ID du ticket.
  #       Code d'authentification (if any)
  #
  # DO    Exécute le ticket si tout est OK
  #
  # OUT   Void
  def run(ticket_id, authentif = nil)
    log("-> Ticket.run(ticket_id=#{ticket_id.inspect}, authentif=#{authentif.inspect})")
    ticket = Ticket.get(ticket_id)
    if ticket.nil?
      log("Le ticket #{ticket_id.inspect} est expiré")
      return erreur "Désolé mais ce ticket est expiré."
    end
    # Si ce n'est pas un ticket auto-authentifié et que le visiteur est
    # inconnu, on lui demande de s'identifier.
    if not(ticket.auto_authentified?) && user.guest?
      session['back_to'] = "#{route.to_s}?tik=#{ticket_id}"
      icarien_required('Vous devez vous identifier pour certifier que ce ticket vous appartient')
      # => Redirigé
    end

    ticket_is_valide =  if ticket.auto_authentified?
                          ticket.authentif === authentif
                        else
                          ticket.belongs_to?(user)
                        end
    # En cas de validité du ticket, on peut le jouer, sinon, on produit une
    # erreur
    if ticket_is_valide
      log("Ticket OK (appartient à user), on le joue")
      ticket.run
    else
      erreur "Vous n'êtes pas le destinataire de ce ticket. Je ne peux pas le jouer pour vous."
    end
  end #/ run

end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def run
  begin
    eval(data[:code])
    delete # toujours, après son exécution réussie
  rescue Exception => e
    erreur(e)
    log(e)
  end
end #/ run


end #/Ticket
