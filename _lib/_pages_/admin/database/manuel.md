## Graphic Database

“Graphic Database” est un mode de consultation et d'édition des données de la base de données qui permet un travail confortable avec les données. Il fonctionne par carte, ou "fiche", qui sont chacun des objets de l'application.

Ce document est composé de deux sections principales :

* [Aide sur l'utilisation](admin/database/#utilisation) (pour utiliser au mieux cet assistant graphique)
* [Aide sur la programmation](admin/database/#implementation) (pour l'implémentation)

<a name="utilisation"></a>

### Aide utilisation

#### Filtrage des icariens

Dans la fiche de la liste des icariens, on peut filtrer les icariens de deux manières :

* par le pseudo, en tapant des lettres appartenant au pseudo recherché,
* par le statut, en tapant `statut:` suivi de l'un des statuts `actif`, `inactif`, `recu` ou `candidat`,
* par date en tapant `after:` (pour voir les icariens inscrit après cette date) ou `before:` (pour voir les icariens inscrits avant cette date) suivi d'une date au format `JJ/MM/AAAA` (par exemple `1/1/2018`)
* par les données à l'aide de l'étique `data:` suivie d'une liste de `key=value` séparée par des virgules. Par exemple : `data: date_sortie = null` ou `data: pseudo = "Travis"`

#### Modification d'une donnée

Un champ de texte, en bas de chaque fiche, permet de modifier les données SQL de l'objet (icarien, module, étape, etc.). Puisque l'élément est défini, il suffit de rédiger la partie `SET` de la requête `UPDATE`.

Par exemple, pour modifier la date de sortie d'un icarien (fin de son dernier module), il suffit de taper le code suivant dans le champ :

~~~bash
SET date_sortie = "5789947893"
~~~

> Note : c'est le premier mot — ici "SET" — qui va déterminer comment traiter la ligne de code.

#### Autre action par le champ de code

En plus de la commande `SET`, on peut trouver :

* `DESTROY`. Permet, après confirmation, de détruire l'élément (fonctionne différemment en fonction des types d'objet). Par exemple, pour l'icarien, il n'est pas détruit de la table de données, mais marqué "détruit" dans ses options.

#### Nom de la colonne d'une propriété propre

Pour obtenir le nom d'une propriété à modifier, cliquer sur son libellé dans les données propres (par exemple "Créé le"). Il suffit ensuite de mettre cette propriété `prop` dans le champ sql pour la modifier à l'aide de `SET prop = &lt;valeur&gt;`.

> Noter qu'on peut obtenir les vraies valeurs de date en cliquant sur leur champ. Cf. ci-dessous.

#### Champ date

Les dates (timestamp sur 10 chiffres) sont transformées en dates humaine. Pour obtenir la valeur dans la base, il suffit de cliquer sur le champ et de récupérer la valeur donnée dans le champ.

<a name="implementation"></a>

### Aide programmation

Pour le moment s'inspirer des modules javascript présents pour modifier le comportement ou ajouter des fonctionnalités.
