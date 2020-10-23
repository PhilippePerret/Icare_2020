# TODO LIST

Voir dans GHI les tâches avec le tag 'concours'.

## Comment procéder pour un icarien ?

Il arrive sur la page d'inscription => s'il n'est pas déjà inscrit, on lui met un simple lien "Participer à ce concours" et on crée un enregistrement avec un numéro normal, mais qui ne servira jamais quand l'icarien est identifié (on le relèvera pour lui dans la base)

Note : dans le cas où un icarien non identifié s'inscrit : on recherche dans la table des users si quelqu'un existe avec ce mail => on le signale, on lui dit de s'identifier et de rejoindre le formulaire d'inscription.

Donc :

- Un visiteur (icarien non identifié) arrive et remplit le formulaire d'inscription
- on reconnait un icarien => on lui demande s'il veut participer
- on poursuit comme ci-dessous

- un icarien arrive sur le formulaire d'inscription
- on lui demande simplement s'il veut participer
- si oui, on lui crée un enregistrement pour le concours en cours
- on ne lui donne pas son numéro d'inscription qui servira seulement en interne

Dans la procédure de reconnexion, on reconnecte automatiquement un icarien identifié.

note : sur la page d'identification, on indique qu'un icarien doit être identifié sur le site, pour être identifié sur le concours


## Identifiant d'un inscrit

L'identifiant est construit avec la date et le temps courant au moment de l'inscription : Année, mois, jour, heures, minutes et secondes. Par exemple 2020, 11, 13, 10, 44, 32 sans espaces ni virgules ("20201113104432"). Si cet identifiant est déjà trouvé dans la base (très improbable, on ajoute une seconde.)
