# Page Checker

Au départ, Page Checker est un vérificateur de lien, pour trouver les "broken links" dans les pages d'un site. Il s'est au fil de la réflexion métamorphosé en checker de page, qui a la même fonction, mais qui peut vérifier en plus que la page est conforme.

C'est un outil totalement autonome qu'on doit pouvoir utiliser sur n'importe quel site.

## TODO

* traitement dans différents contextes, par exemple avec un utilisateur identifié
* traiter l'aspect des pages (ce qu'on doit trouver dans une url précise, avec le fichier pages_data.yaml)
* checker la présence/existence des images (img/src). Est-ce qu'il faut le faire par SSH ?


## Pour essayer du code

On peut utiliser la commande `./PageChecker.rb --try` pour jouer le code défini dans la méthode `[PageChecker#try_something](/Users/philippeperret/Sites/AlwaysData/Icare_2020/spec/PageChecker/xlib/_required/_then/PageChecker/page_checker_class.rb:74)`

## Synopsis

PageChecker parcourt les liens définis dans les pages à partir d'une page donnée, vérifie si la cible existe et si elle est conforme à la définition qu'on en a fait.

## Définition de la conformité d'une page

On peut définir la conformité d'une page à l'aide de :

* son titre (une balise HTML et un texte à trouver),
* son contenu (on s'attend à trouver telle ou telle chose),
* ses liens (on s'attend à trouver tel ou tel lien). Avec des liens des peuvent être communs à toutes les pages,

## Options à tenir en compte

* Prendre en compte le statut de l'utilisateur. Les pages sont différentes suivant qu'il est identifié ou non (comment prendre en compte ça ? il faudrait décrire la procédure d'identification)

## Fonctionnement

PageChecker fonctionne avec un fichier `pages_data.yaml` qui définit les données des pages, un fichier `config.yaml` qui définit la configuration. On utilise ensuite le Terminal ou la Console pour lancer le fichier racine `PageChecker.rb` qui se trouve à la racine du dossier en lui fournissant l'adresse URL à checker et quelques options.

## Check d'une adresse seule

On peut tester une adresse seule en utilisant l'option `--not-deep`.

~~~
./PageChecker.rb http://mon/url --not-deep
~~~
