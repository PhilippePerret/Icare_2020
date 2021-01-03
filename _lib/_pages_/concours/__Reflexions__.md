# Réflexions sur le concours


## Calcul des notes et des positions

Pour le moment, dès qu'on veut afficher les fiches de synopsis ou de lecture, il faut tout recalculer. Cela ne pose pas véritablement de problème lorsque c'est la liste complète des synopsis qu'il faut afficher, mais cela peut être dépensier en énergie si c'est juste pour afficher une fiche de lecture.

L'idée serait donc d'enregistrer les valeurs dans la table et de ne les recalculer que lorsqu'une fiche d'évaluation est modifiée.

* on enregistre une fiche d'évaluation
* => on renseigne la donnée qui consigne la date de dernière modification
* on demande l'affiche d'une fiche de lecture
* le programme regarde la date de dernière modification générale (DDM)
* le programme regarde la date de dernier calcul des fiches (DDC)
* si DDM > DDC alors le calcul est recommencé
  * le programme consigne la date de dernier calcul

Quelles données faudrait-il consigner ?

Au minimum :

- la note générale de présélection du synopsis — et avant — (pre_note dans la base)
- la note générale de prix — fin_note — au cours de l'établissement du palmarès
- la position du synopsis

CONCLUSION : étant donné qu'il n'y aura pas forcément beaucoup de projet (< 200), on peut pour le moment tout recalculer chaque fois.
