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
