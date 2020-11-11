# Réflexion

Pour le moment, j'ai :

* la classe Synopsis
* la classe FicheLecture
* la classe ENote et ENotesFL

Je trouve ça beaucoup trop compliqué, alors que voilà ce dont on a besoin

Voilà ce dont on a besoin :

* on doit pouvoir rassembler les notes par sujets (:projet, :personnages, :intrigues, etc.)
*

### Conclusion

* Les notes appartiennent au synopsis.
  * Deux méthodes :
    * `#note_totale` qui produit la note rassemblant toutes les évaluations à un moment M donné.
    * `#note_evaluateur` qui produit la note d'un évaluateur donné à un moment M (l'évaluateur courant, normalement, sauf que je pourrais vouloir voir les notes qu'attribuent les évaluateurs)
  * Noter qu'il y a la note pour les présélections et la note pour le palmarès.
    Peut-être une seule méthode `note` avec trois arguments : `note(preselection|palmares, totale|evaluateur[, options])`

* la classe FicheLecture doit se consacrer entièrement et seulement à la production de la Fiche de lecture d'un projet. Elle peut avoir seulement deux formes :
  * la forme générale, rassemblant toutes les notes de tous les membres
  * la forme propre à un évaluateur, avec ses propres notes seulement (il ne doit pas pouvoir voir l'évaluation des autres, au risque de modifier ses notes en conséquence)

* On doit centraliser le parsing du score dans un seul fichier, pour toutes les manipulations. Se servir du module de calcul.
