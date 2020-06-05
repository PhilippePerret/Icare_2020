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
      # Si la méthode param(:op) n'est pas connue du watcher, c'est qu'il
      # s'agit d'une méthode définie dans le dossier du processus. Il faut
      # donc le requérir avant de l'appeler.
      watcher.require_folder_processus unless watcher.respond_to?(param(:op).to_sym)
      watcher.send(param(:op).to_sym) # :run et :unrun principalement
    elsif param(:op)
      # Une opération sans ticket
      user.watchers.send(param(:op).to_sym)
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', user)
  end
end #/HTML
