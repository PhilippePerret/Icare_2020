# encoding: UTF-8
require_module('user/modules')
class Watcher < ContainerClass
  def confirm_virement
    log("-> confirm_virement")
    # On ajoute le paiement en créant un enregistrement
    require './_lib/pages/modules/paiement/lib/user_paiement'
    owner.add_paiement(objet_id) # fait tout
  end # / confirm_virement

end # /Watcher < ContainerClass
