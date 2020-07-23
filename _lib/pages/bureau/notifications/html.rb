# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "#{RETOUR_BUREAU}#{EMO_PUNAISE.page_title+ISPACE}Notifications".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    if param(:wid)
      watcher = Watcher.get(param(:wid))
      method = param(:op).to_sym
      watcher.require_folder_processus
      watcher.send(method) # :run et :unrun principalement
    elsif param(:op)
      user.watchers.send(param(:op).to_sym)
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb(STRINGS[:body], user)
  end
end #/HTML
