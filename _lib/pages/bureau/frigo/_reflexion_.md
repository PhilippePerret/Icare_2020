# Réflexion à propos des discussions de frigo

Maintenant qu'on peut être plus de deux pour faire une discussion frigo, on doit traiter les tables différemment :

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
