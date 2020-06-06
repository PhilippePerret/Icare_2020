# encoding: UTF-8
=begin
  Constantes pour les watchers

  C'est notamment dans ce fichier que doivent être définis tous les types
  de watchers.

  Noter que toutes les données consignées ici dans chaque élément sont
  enregistrées dans le watcher en base de données, sauf :required qui permet
  de s'assurer que toutes les données ont bien été fournies.

  Noter également qu'on ne peut pas, pour le moment, récupérer ces données
  depuis le watcher lui-même (il faudrait pour ça enregister sa clé dans la
  table, mais alors, il serait inutile d'enregistrer autant d'informations ; on
  saurait, par exemple, que :create_icmodule concerne un objet de classe
  IcModule et le processus 'start' — ne serait-ce pas mieux, finalement ?)
=end

DATA_WATCHERS = {
  # --- USER ---
  validation_adresse_mail: {
    titre: 'Validation de votre adresse mail'.freeze,
    relpath: 'User/valid_mail'.freeze
  },
  validation_inscription: {
    titre: 'Validation inscription',
    relpath: 'User/signup',
    actu_id: 'SIGNUP'
  },
  # --- LES MODULES ---
  start_module:  {
    titre:  'Démarrage du module',
    relpath:'IcModule/start',
    actu_id: 'STARTMOD'
  },
  commande_module:    {
    titre: 'Commande de module',
    relpath:'AbsModule/commande',
    actu_id: nil
  }
}
