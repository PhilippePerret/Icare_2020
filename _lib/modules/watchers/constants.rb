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
  # --- LES MODULES ---
  creation_icmodule:  {
    titre:  'Démarrage de module',
    relpath:'IcModule/start'
  },
  commande_module:    {
    titre: 'Commande de module',
    relpath:'AbsModule/commande'
  }
}
