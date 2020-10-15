# Gestion des BD

## TODO

`ghi list -L dbfiches` pour voir la liste des choses à faire

## Présentation

L'idée de cette partie est de pouvoir gérer la base de données de façon très "graphique", avec des "fiches" que je mets de côté et que je peux déplacer à loisir.

Idée de scénario : je dois créer un watcher pour une étape de module d'un icarien. Je choisis l'icarien dans une liste. Le programme m'affiche l'icarien dans une fiche, avec ses modules. Je peux cliquer sur un titre de module, ce qui ouvre la fiche du module dans laquelle on trouve ses étapes. Je peux cliquer sur une étape et voir ses informations, ses documents, etc. Je peux mettre la fiche de côté,

## PRINCIPES

Quand on remonte le résultat d'une requête, on a deux solutions :
* Afficher le résultat sous forme de liste (par exemple avec la liste des icariens). Quand on clique sur un élément de cette liste, on ouvre une fiche du type
* Afficher une fiche.

Note : cela ne devrait-il pas dépendre du nombre d'éléments ?

## Fonctionnalités à implémenter

* Enregistrement de l'état actuel