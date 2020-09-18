# encoding: UTF-8
# frozen_string_literal: true
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
    titre: 'Validation de votre adresse mail',
    relpath: 'User/valid_mail'
  },
  validation_inscription: {
    titre: 'Validation inscription',
    relpath: 'User/signup',
    actu_id: 'SIGNUP'
  },
  # --- LES MODULES ---
  start_module:  {
    titre:  'Démarrage du module d’apprentissage',
    relpath:'IcModule/start',
    actu_id: 'STARTMOD'
  },
  paiement_module: {
    titre: 'Paiement du module',
    relpath: 'IcModule/paiement',
    actu_id: nil
  },
  annonce_virement: {
    titre: 'Annonce de virement IBAN',
    relpath: 'IcModule/annonce_virement',
    actu_id: nil,
    next: 'confirm_virement'
  },
  confirm_virement: {
    titre: 'Confirmation du virement IBAN',
    titre_mail_user: 'Votre facture',
    relpath: 'IcModule/confirm_virement',
    actu_id: nil,
    next: nil
  },
  # --- Parcours des documents d'une icétape ---
  send_work: {
    titre: 'Envoi des documents de travail',
    relpath: 'IcEtape/send_work',
    actu_id: "SENDWORK",
    next: 'download_work'
  },
  download_work: {
    titre: 'Chargement du travail de l’étape',
    relpath: 'IcEtape/download_work',
    next: 'send_comments',
    actu_id: nil
  },
  send_comments: {
    titre: 'Travail à l’étude',
    relpath: 'IcEtape/send_comments',
    next: 'download_comments',
    actu_id: "COMMENTS"
  },
  changement_etape: {
    titre: 'Changement d’étape',
    relpath: 'IcEtape/change',
    actu_id: "CHGETAPE",
    next: nil
  },
  download_comments: {
    titre: 'Chargement des commentaires',
    relpath: 'IcEtape/download_comments',
    actu_id: nil,
    next: 'qdd_depot'
  },
  qdd_depot: {
    titre: 'Dépôt sur le Quai des docs',
    relpath: 'IcEtape/qdd_depot',
    actu_id: "QDDDEPOT",
    next: 'qdd_sharing'
  },
  qdd_sharing: {
    titre: 'Définition du partage des documents',
    relpath: 'IcEtape/qdd_sharing',
    actu_id: "QDDSHARING",
    next: nil
  },
  qdd_coter: {
    titre: 'Coter et commenter',
    relpath: 'IcDocument/cotes_n_comments',
    actu_id: nil,
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
    titre: 'Question mini-faq',
    relpath: 'MiniFaq/answer_question',
    actu_id: nil,
    next: nil
  },

  # --- DIVERS ---
  destroy_discussion: {
    titre:    'Destruction d’une discussion',
    relpath:  'FrigoDiscussion/destroy',
    actu_id: nil,
    next: nil
  },
}
