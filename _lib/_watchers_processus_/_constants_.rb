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
  paiement_module: {
    titre: 'Paiement du module'.freeze,
    relpath: 'IcModule/paiement'.freeze,
    actu_id: nil
  },
  # --- Parcours des documents d'une icétape ---
  send_work: {
    titre: 'Envoi des documents de travail'.freeze,
    relpath: 'IcEtape/send_work'.freeze,
    actu_id: "SENDWORK",
    next: 'download_work'
  },
  download_work: {
    titre: 'Chargement du travail de l’étape'.freeze,
    relpath: 'IcEtape/download_work'.freeze,
    next: 'send_comments',
    actu_id: nil
  },
  send_comments: {
    titre: 'Travail à l’étude'.freeze,
    relpath: 'IcEtape/send_comments'.freeze,
    next: 'download_comments'.freeze,
    actu_id: "COMMENTS"
  },
  changement_etape: {
    titre: 'Changement d’étape'.freeze,
    relpath: 'IcEtape/change'.freeze,
    actu_id: "CHGETAPE",
    next: nil
  },
  download_comments: {
    titre: 'Chargement des commentaires'.freeze,
    relpath: 'IcEtape/download_comments'.freeze,
    actu_id: nil,
    next: 'qdd_depot'.freeze
  },
  qdd_depot: {
    titre: 'Dépôt sur le Quai des docs'.freeze,
    relpath: 'IcEtape/qdd_depot'.freeze,
    actu_id: "QDDDEPOT",
    next: 'qdd_sharing'.freeze
  },
  qdd_sharing: {
    titre: 'Définition du partage des documents'.freeze,
    relpath: 'IcEtape/qdd_sharing'.freeze,
    actu_id: "",
    next: nil
  },
  # --- Modules ---
  commande_module:    {
    titre: 'Commande de module',
    relpath:'AbsModule/commande',
    actu_id: nil
  },
  # --- Question mini-faq ---
  question_faq: {
    titre: 'Question mini-faq'.freeze,
    relpath: 'MiniFaq/answer_question'.freeze,
    actu_id: nil,
    next: nil
  }
}
