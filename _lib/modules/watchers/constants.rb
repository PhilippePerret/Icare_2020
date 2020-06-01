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
    vu:         false,
    required: [:objet_id, :user_id]
  }
}
