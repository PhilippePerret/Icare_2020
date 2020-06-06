# encoding: UTF-8
=begin

=end

def redirect_to(route, options = nil)
  Retour.redirect_to(route, options)
end

# Joue (run) le watcher d'identifiant +watcher_id+
#
# Utilisé principalement par les mails et tickets
def run_watcher(watcher_id)
  require_module('watchers') unless defined?(Watcher)
  watcher = Watcher.get(watcher_id)
  return erreur("Désolé mais cette notification n’est plus d’actualité.".freeze) if watcher.nil?
  watcher.run
end #/ run_watcher

# Joue un ticket
def run_ticket(ticket_id)
  if user.guest?
    session['back_to'] = "#{route.to_s}?tik=#{ticket_id}"
    icarien_required('Vous devez vous identifier pour certifier que ce ticket vous appartient'.freeze)
  end
  require_module('ticket')
  ticket = Ticket.get(ticket_id)
  if ticket.nil?
    erreur "Désolé mais ce ticket est expiré.".freeze
  elsif ticket.belongs_to?(user)
    ticket.run
  else
    erreur "Vous n'êtes pas le destinataire de ce ticket. Je ne peux pas le jouer pour vous.".freeze
  end
end #/ run_ticket
