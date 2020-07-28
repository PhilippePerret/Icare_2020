# encoding: UTF-8
require_module('user/modules')
class Watcher < ContainerClass
  def annonce_virement

    # On n'a rien de particulier à faire ici puisque cette notification
    # se contente de m'envoyer un message pour me dire que l'user confirme
    # son virement. C'est donc le watcher `confirm_virement` qui doit
    # traiter la suite des opérations.

  end # / annonce_virement
end # /Watcher < ContainerClass
