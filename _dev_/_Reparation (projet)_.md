# Projet de réparation

Je prends ici les notes sur les réparations qui seront à faire (en fonction des erreurs que je trouve en ré-implantant l'atelier).

* Mauvaises dates d'inscription
  * => Prendre la date de démarrage du premier module et enlever 2 jours
* Dans les pauses de IcModule, la donnée n'est pas toujours bien formatée
  C'est un string JSON (ok) qui contient parfois des hash (OK) et parfois
  des string JSON (qu'il faut parser aussi)
* Deux mises en pause pour le même module, sans arrêt de pause (Triskell). Note : il faut avoir fait la correction avant.
* Des pauses depuis trop longtemps :
  * il faut ajouter une fin de pause à icmodule.pauses
  * il faut indiquer l'étape terminé
  * il faut interrompre le module
* Des envois de document (icdocument.time_original) qui sont trop proches de l'envoi des commentaires (icdocument.time_comments).
  * voir si mettre time_original et created_at résoud le problème
  * voir si mettre time_comments un peu avant la fin de l'étape résoud le problème
