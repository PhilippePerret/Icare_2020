# encoding: UTF-8
require_module('absmodules')

class Watcher < ContainerClass
  def commande
    require_module('icmodules')
    # Vérifications préliminaires
    raise "Vous suivez déjà un module !" if owner.actif?
    # Créer un nouvel IcModule pour l'icarien
    # ATTENTION : les données envoyées sont celles qui seront ajoutées
    # dans la base de données
    icmodule_id = IcModule.create_new_for(user_id:owner.id, absmodule_id:objet_id, user:owner)
    # Message de confirmation
    message "Le nouveau module ##{icmodule_id} a été préparé pour #{owner.pseudo}."
  end #/ commande

  # Quand la commande est refusée
  def contre_commande
    message "Je refuse la commande"
  end #/ contre_commande
end #/Watcher < ContainerClass
