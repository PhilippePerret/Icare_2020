
# Nombre de messages non lu

La date de dernière consultation d'une discussion par un user est consignée dans la colonne `last_check_at` de la table `frigo_users`. Pour connaitre le nombre de messages non lus par l'user ou moi, il suffit donc de compter tous les messages qui :
  * sont postérieurs à last_check_at
  * appartiennent à des discussions suivies par l'user

  ~~~SQL
  SELECT COUNT(*)
    FROM `frigo_messages` AS mes
    INNER JOIN `frigo_discussions` AS dis ON mes.discussion_id = dis.id
    INNER JOIN `frigo_users` AS u ON dis.user_id = user_id &&
    WHERE mes.created_at > "last_checked_at"
      AND u.user_id = user_id
    GROUP BY dis.user_id
  ~~~
