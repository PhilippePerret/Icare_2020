# Todo list

## Rapid list

* Établir le moyen de produire les fiches de lecture de façon fine, avec le traitement de la propriété `:if`.
  Peut-être qu'il peut y avoir deux choses différentes :
    1. un texte radicalement différent en fonction du contexte (comment définir ce contexte ?)
    2. un texte qui varie dans le détail (le tout petit détail parfois, comme 'une histoire passionnante' au lieu de 'une histoire' en fonction de certains critères *critere*)
      Par exemple dans le texte "… pourrait aider cette %{histoire} à devenir"
      avec une méthode {histoire: histoire_per_critere}, donc une méthode `histoire_per_critere` qui renverrait 'histoire' ou 'pitoyable histoire' ou 'formidable histoire' en fonction du contexte, de certains critères.
      On peut développer à l'infini cette utilisation, avec de éléments de détail (une méthode qui ne servirait qu'à un endroit) comme des éléments généraux (comme 'histoire') ci-dessus
      QUESTION : faut-il les mettre dans des balises spéciales ? Oui, sinon, on aurait tout à calculer chaque fois et ça peut devenir lourd.
* Finaliser les textes
* transmission de la fiche de lecture


## Toutes les tâches

Voir surtout avec `ghi list` avec le label 'concours' (`ghi list -L concours`). Ici, on ne place que les informations qui ont besoin d'être réfléchies

## Command pour HOME

open -a Safari "http://localhost/AlwaysData/Icare_2020"; cd "/Users/philippeperret/Sites/AlwaysData/Icare_2020";open -a Typora "./_dev_/Manuel/Manuel_developper.md";open -a Aperçu "./_dev_/Manuel/Manuel_developper.pdf"

## Correction des images

Faire un script qui 1) produit toutes les dimensions des images et 2) produit les balises nécessaires.
