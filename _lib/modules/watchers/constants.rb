# encoding: UTF-8
=begin
  Constantes pour les watchers

  C'est notamment dans ce fichier que doivent être définis tous les types
  de watchers.

=end

DATA_WATCHERS = {
  creation_icmodule: {
    objet:      'IcModule',
    processus:  'start',
    vu_admin:   true, # puisque c'est l'admin qui le crée
    required: [:objet_id, :user_id]
  },

  # Pour la commande d'un module
  commande_module: {
    objet:      'AbsModule',
    processus:  'commande',
    vu_user:    true, # puisque c'est lui qui commande
    required: [:objet_id, :user_id]
  }
}
