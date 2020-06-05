# encoding: UTF-8
class HTML
  def titre
    "#{RETOUR_ADMIN}🎮 Notifications".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    require_module('watchers')
    require_module('form')
    if param(:wid)
      watcher = Watcher.get(param(:wid))
      watcher.send(param(:op).to_sym) # :run et :unrun principalement
    elsif param(:op)
      user.watchers.send(param(:op).to_sym)
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', user)
  end
end #/HTML
