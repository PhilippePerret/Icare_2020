# Réflexions sur le concours

## Nom Evaluator

Maintenant qu'un `Evaluator` peut être administrateur ou concurrent, je me demande si c'est la bonne définition. Ne pourrait-on pas utiliser la classe `User` pour ça, avec les méthodes suivantes :

* User#concurrent? (qui existe déjà)
* User#admin? (qui existe déjà)
* User#jury1?
* User#jury2?
* User#evaluator? (lorsque jury1? || jury2?)

Un des avantages possibles, c'est qu'on pourrait utiliser une seule boite de login pour tout (ou, pour le moment, laisser quand même séparés le login de l'atelier avec le login du concours)

MAIS : en fait, on ne peut pas trop le faire avec le concurrent, qui possède trop de méthodes particulières qui risque de rentrer en conflit avec les données User normales (par exemple la propriété :options qui est radicalement différente). Il serait peut-être possible de "couper la poire en deux" et d'utiliser les méthodes User ci-dessus quand c'est pertinent, par exemple pour l'affichage des fiches de lecture.

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
