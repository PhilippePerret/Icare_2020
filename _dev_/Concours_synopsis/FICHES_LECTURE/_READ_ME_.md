# Fiches de lecture du concours de Synopsis

L'idée de ce dossier est de produire les fiches de lecture localement, "en toute tranquillité", grâce à la commande :

~~~
icare concours fiches_lecture --build
~~~

## Avantages et inconvénients

### Avantages

* Rien à protéger à ce niveau-là, il est impossible à quiconque de produire les fiches.
* Tous les textes qui permettent de les construire sont seulement en local, c'est plus léger,
* Les tests sont facilités, on peut imaginer des tests unitaires seulement et travailler plus de façon granulaire, donc.
* Je ne suis plus astreint à attendre la fin du concours, je peux tester la fabrication très en amont.

### Inconvénients

* Je suis le seul qui peut lancer la fabrication des fiches (est-ce vraiment un inconvénient ?…)

## Synopsis

* On rapatrie en local toutes les évaluations (pour les tests, on les prend en local)
* on construit les fiches de lecture
* on les transmet sur le site en distant
