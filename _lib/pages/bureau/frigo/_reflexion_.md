# Réflexion à propos des discussions de frigo

Maintenant qu'on peut être plus de deux pour faire une discussion frigo, on doit traiter les tables différemment :

# Nombre de messages non lu

La date de dernière consultation d'une discussion par un user est consignée dans la colonne `last_check_at` de la table `frigo_users`. Pour connaitre le nombre de messages non lus par l'user ou moi, il suffit donc de compter tous les messages qui :
  * sont postérieurs à last_check_at
  * appartiennent à des discussions suivies par l'user

  ~~~SQL
  SELECT COUNT(*)
    FROM `frigo_messages` AS mes
    INNER JOIN `frigo_discussions` AS dis ON mes.discussion_id = dis.id
    INNER JOIN `frigo_users` AS u ON dis.user_id = user_id &&
    WHERE mes.created_at > last_checked_at
      AND u.user_id = user_id
    GROUP BY dis.user_id
  ~~~

* une table contient toutes les discussions, avec leur créateur (user_id) seulement

  `frigo_discussions`
  id        # ID de la discussion
  user_id   # ID du créateur de la discussion
  last_message_id # ID du dernier message envoyé

* une table contient les participant aux discussions. C'est une table de croisement entre `frigo_discussions` et `users`

  `frigo_participants`
  discussion_id et user_id permettent de faire le lien
  discussion_id   # ID de la discussion (dans frigo_discussions)
  user_id         # ID de l'auteur qui participe à la discussion
  last_message_id # ID du dernier message (posté ou lu) pour savoir s'il y en
                  # a des nouveau (en le comparent au last_message_id de la discussion)


* une table contient les messages
  discussion_id   # ID de la discussion (dans frigo_discussions)
  user_id         # ID de l'auteur du message
