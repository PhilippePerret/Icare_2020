# Todo list

## Rapid list

* Détruire le fichier fiche_lecture.html après avoir fait le PDF
* Voir, pour la fiche de lecture, si on ne pourrait pas fonctionner selon ce principe :
  On passe en revue toutes les catégories de l'évaluation
  en transformant la note en lettre
  si le fichier texte contient un texte correspondant, on l'écrit
  Il suffirait juste de définir l'ordre pour que les textes soient construits.
  Par exempe, on a la catégorie 'p:cohe' (cohérence des personnages)
  Si on trouve dans le fichier texte :
    p:
      cohe:
        A: Les lecteurs ont apprécié la cohérence des personnages
        D: Les lecteurs ont regretté le manque de cohérence des personnages
  Le problème est que ça risque de donner un texte un peu trop découpé.

* Ajouter l'ID à la liste des projets étudiés (???)
* Afficher le classement des projets, après leur étude, dans '--build'
* poursuivre le développement avec les balises
  *
  FORME :
    SI > 15

    SI entre 10 et 15
      AMÉLIORATIONS POSSIBLES
    Forme/structure < 10
    RAISONS
      Prédictibilité des intrigues ?
      PROBLÈME :
        'predic' Prédictibilité < 10 => intrigues trop prévisibles
      RAISONS :
        "i:fO"    Originalité des intrigues
          SI > 10   malgré l'originalité des intrigues
          SI < 10   peut-être à cause du manque d'originalité des intrigues
      MALGRÉ
        "i:adth"  => "malgré l'adéquation de ces intrigues avec le thème" / <rien>
        "i:cohe"  => "Bien que les intrigues soient cohérences" / "peut-être à cause de certaines incohérences"
* Finaliser les textes
* transmission de la fiche de lecture sur le site distant
* chargement de la fiche de lecture


## Toutes les tâches

Voir surtout avec `ghi list` avec le label 'concours' (`ghi list -L concours`). Ici, on ne place que les informations qui ont besoin d'être réfléchies

## Command pour HOME

open -a Safari "http://localhost/AlwaysData/Icare_2020"; cd "/Users/philippeperret/Sites/AlwaysData/Icare_2020";open -a Typora "./_dev_/Manuel/Manuel_developper.md";open -a Aperçu "./_dev_/Manuel/Manuel_developper.pdf"

## Correction des images

Faire un script qui 1) produit toutes les dimensions des images et 2) produit les balises nécessaires.
