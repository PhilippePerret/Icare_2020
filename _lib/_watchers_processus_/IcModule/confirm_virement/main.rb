# encoding: UTF-8
# frozen_string_literal: true
require_module('user/modules')
class Watcher < ContainerClass
  def confirm_virement
    log("-> confirm_virement")
    # On ajoute le paiement en créant un enregistrement
    require "#{FOLD_REL_PAGES}/modules/paiement/lib/user_paiement"
    owner.add_paiement(objet_id) # fait tout
  end # / confirm_virement
end # /Watcher < ContainerClass
