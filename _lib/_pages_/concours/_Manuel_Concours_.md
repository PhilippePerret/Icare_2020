# Concour<br>Manuel d'utilisation

# Étape du concours

L'étape courante du concours détermine là où on se trouve du concours. Elle est maintenue par la propriété `step` dans la base de données

| step | Description                |          | Note                                                         |
| ---- | -------------------------- | -------- | ------------------------------------------------------------ |
| 0    | Concours en attente        | *état*   | Le concours est en attente, rien n’est affiché.<br />Un visiteur quelconque peut s’inscrire (notamment pour être averti) |
|      |                            | *action* | Déterminer le prochain thème.<br />Composer le jury.         |
| 1    | Le concours est en cours   | *état*   | Un visiteur peut s’inscrire, un visiteur peut transmettre son synopsis.<br />Un évaluateur peut commencer à lire le synopsis et l’évaluer.<br />Le concours est annoncé sur l’atelier.<br />Le thème est déterminé, le concurrent peut commencer à écrire. |
|      |                            | *action* | Les concurrents sont avertis du lancement du concours.       |
| 2    | Échéance                   | *état*   | Un visiteur peut toujours s’inscrire, mais pour la session suivante (avertissement).<br />Un concurrent ne peut plus transmettre de document.<br />Un évaluateur peut toujours lire et évaluer le synopsis.<br />L’administrateur ne peut pas produire les fiches de lecture (officiellement) ni afficher les résultats. |
|      |                            | *action* | Un mail est envoyé aux concurrents pour annoncer la fin de l’échéance et décrire un peu la suite (sélection). |
| 3    | Première sélection         | *état*   | Les synopsis sont sélectionnés pour la sélection finale.<br />Un mail annonce aux perdants qu’ils n’ont pas été retenus.<br />Un mail annonce aux gagnants du premier tour qu’ils ont été retenus. |
|      |                            | *action* | Mail envoyé aux concurrents pour annonce de la première sélection |
| 5    | Palmarès                   | *état*   | L’administrateur peut afficher les résultats, produire les fiches de lectures, informer les concurrents des résultats.<br />Les concurrents peuvent consulter leurs résultats sur leur espace.<br />Un visiteur quelconque peut toujours s’inscrire, mais pour la session suivante (avertissement). |
|      |                            | *action* | Mail d’annonce des résultats aux concurrents                 |
| 8    | Fin officielle du concours | *état*   | Le concours n’est plus annoncé sur l’atelier.                |
|      |                            | *action* | Mail de fin de concours, remerciements aux concurrents, annonce de la prochaine session.<br />Remerciements aux membres du jury. |
| 9    | Concours nettoyé           | *état*   | Les éléments du concours sont nettoyés pour permettre le lancement et le traitement du prochain concours. |

