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


#### Fermeture des fiches

Pour fermer une fiche, on clique sur la point rouge qui se trouve à droite en regard du titre de la fiche.

Pour fermer tous les ascendants de la fiche — i.e. ses “propriétaires” —, on tient la touche `⇧` appuyée. Par exemple, si on a ouvert :

~~~
Icarien -> Un de ses modules -> une étape -> un document
~~~

… alors si on clique sur la case de fermeture du document en tenant la touche majuscule appuyée, alors toutes les fiches “ascendantes” seront fermées, c'est-à-dire la fiche de l'étape, la fiche du module et la fiche de l'icarien.


#### Additionneur de temps

L'additionneur de temps, en haut de la page (sur le plan de travail) permet de calculer des dates par ajout ou soustraction.

Il faut respecter les usages suivant :

* la “durée littéraire” doit être exprimée par `minute`, `minutes`, `jour`, `jours`, `semaine`, `semaines` ou `mois` (ou leurs équivalents en anglais),
* toujours coller (i.e. sans espace) le nombre et la durée littéraire : **`4jours`**, **`1semaine`**,
* pour les secondes, mettre seulement le chiffre (par exemple `176543678 + 25`),
* une opération doit être `+` ou `-` seulement,
* toujours laisser des espaces avant et après chaque terme ou opération,
* après un signe `+` ou `-` on peut enchainer les durées sans remettre le signe (par exemple `1516144258 + 2jours 2minutes 15 - 1semaine`).

**Exemples**

`1654567 + 4jours 2minutes - 12` sera une requête valide tandis que `1654567+4 jours+2 minutes-12` sera tout à fait invalide.

**Récupération du timestamp d’une date**

Pour récupérer le timestamp d'une date (nombre de secondes depuis le 1er janvier 1970), il suffit de cliquer sur le champ affichant la date au format humain.

---------------------------------------------------------------------

<a name="implementation"></a>

### Aide programmation

Pour le moment s'inspirer des modules javascript présents pour modifier le comportement ou ajouter des fonctionnalités.
