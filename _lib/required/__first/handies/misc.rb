# encoding: UTF-8
=begin

=end

def redirect_to(route, options = nil)
  Route.redirect_to(route, options)
end

# Joue (run) le watcher d'identifiant +watcher_id+
#
# Utilisé principalement par les mails et tickets
def run_watcher(watcher_id)
  log("-> run_watcher(watcher_id=#{watcher_id.inspect})")
  require_module('watchers') unless defined?(Watcher)
  watcher = Watcher.get(watcher_id)
  if watcher.exists?
    watcher.run
  else
    return erreur("Désolé mais cette notification n’est plus d’actualité (##{watcher_id}).".freeze)
  end
end #/ run_watcher

# Joue un ticket
def run_ticket(ticket_id)
  log("-> run_ticket(ticket_id=#{ticket_id.inspect})")
  if user.guest?
    session['back_to'] = "#{route.to_s}?tik=#{ticket_id}"
    icarien_required('Vous devez vous identifier pour certifier que ce ticket vous appartient'.freeze)
  end
  require_module('ticket')
  ticket = Ticket.get(ticket_id)
  if ticket.nil?
    log("Le ticket #{ticket_id.inspect} est expiré")
    erreur "Désolé mais ce ticket est expiré.".freeze
  elsif ticket.belongs_to?(user)
    log("Ticket OK (appartient à user), on le joue")
    ticket.run
  else
    erreur "Vous n'êtes pas le destinataire de ce ticket. Je ne peux pas le jouer pour vous.".freeze
  end
end #/ run_ticket
