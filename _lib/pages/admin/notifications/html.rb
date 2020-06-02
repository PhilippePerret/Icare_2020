# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "#{RETOUR_ADMIN}🎮 Notifications".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    if param(:wid)
      watcher = Watcher.get(param(:wid))
      watcher.send(param(:op).to_sym) # :run et :unrun principalement
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', user)
  end
end #/HTML
