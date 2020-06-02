# encoding: UTF-8
require_module('absmodules')
class AbsModule < ContainerClass
  def commande
    message "J'accepte la commande"
  end #/ commande

  # Quand la commande est refusée
  def contre_commande
    message "Je refuse la commande"
  end #/ contre_commande
end #/AbsModule < ContainerClass
