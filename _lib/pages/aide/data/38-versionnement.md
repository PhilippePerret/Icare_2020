### Comment numéroter ses versions de document ?



Pour donner des numéros de versions pertinents aux documents de travail, on peut s’inspirer de l’utilisation qu’en font les développeurs informatiques qui ont recours à une numérotation assez stricte, en tout cas performante, de leurs applications.

Cette numérotation s’appuie sur trois chiffres, par exemple « 12.4.356 ».

* Le premier numéro est le numéro majeur de version (ou  **version majeure**),
* le deuxième numéro est le numéro mineur de version (ou **version mineure**),
* le troisième numéro correspond au **numéro de patch**.

On peut n’indiquer pour un document que le numéro de version majeur (par exemple « v3 »), ou le numéro de version majeure et de version mineure sans le numéro de « patch » (par exemple, « v.3.12 »).



#### Le tout premier document

Le tout premier document peut porter le numéro de version « 1 » mais peut aussi, si l’on souhaite suggérer un premier jet, ou une version pas encore « lisible porte ouverte » (comme le dirait Stephen King), on peut utiliser le numéro « 0 » (les développeurs l’utilisent pour indiquer une version encore incomplète, en développement).



#### Règles de changement de versions

Notons pour commencer que pour les versions majeures et mineurs, les changements sont parfois subjectifs, pas toujours évidents à déterminer.

On peut appliquer quelques règles simples pour appliquer de « bons » numéros de version.

* Un numéro absent vaut toujours 1. Donc si on abrège la version « v1 ». Il s’agira en fait de la version « 1.1.1 ». Si on abrège « 12.4 », il s’agira de « 12.4.1. ». Noter que c’est utile seulement lorsque l’on numérotera la version ou sous-version suivante.
* **On change de version majeure lors de changements importants**. Lorsque, par exemple, une nouvelle rédaction complète a été terminée. Lorsqu’un élément important de l’histoire, comme la `QDF` a été modifiée. Lorsqu’un nouveau personnage important a été introduit. Et tout autre changement « majeur ».
* **On change de version mineure lors de changements moindres**. Lorsque l’histoire — ou le document — ne change pas de façon radicale, on peut changer seulement la version mineure. Par exemple lors d’une nouvelle rédaction qui n’a pas modifié en profondeur l’ancien texte et l’histoire. 
* **On change le numéro de patch pour tout changement mineur**. On peut changer de numéro de patch pour tout changement, même le plus infime, une simple et unique correction orthographique, un changement de photo, la correction de deux coquilles. 
  C’est particulièrement intéressant et utile lorsque l’on transmet son document à quelqu’un. Souvent — trop souvent… — on s’aperçoit en relisant le texte, qu’une faute a été laissée dans la version « 12.4.13 ». Dans ce cas, on corrige la faute et on renomme la version « 12.4.14 ».



#### Numérotation pour les documents d’une même version

Comme vous le savez, un projet peut comporter de nombreux documents : synopsis, pitch, structure, scénier ou scénario (pour le roman), manuscrit, continuité dialoguée, etc.

Pour les numéroter, pour pouvez adopter deux méthodes.

* **Vous ne tenez aucun compte des numéros de version des autres documents**, vous incrémentez normalement, depuis 0 ou 1, un document quelconque. Par exemple, si vous êtes à la version 2.4 de votre synopsis et que vous attaquez la continuité dialoguée, cette continuité portera le numéro « v0 » ou « v0.1.1 ». L’avantage de cette méthode est que le numéro de chaque document correspond vraiment au travail qui a été effectué sur lui, au nombre de modifications majeures et mineures qu’il a subi. Le désavantage, c’est qu’il est plus difficile de retrouver la correspondance entre les différents document. Ici, comment savoir que la version « v.0.1.1 » du scénario correspond à la version « v2.4 » du synopsis ?
* **Vous tenez compte des numéros de version des autres documents**. Dans ce cas, un nouveau document abordé portera toujours le numéro des autres documents correspondant. Si vous en êtes à la version « v2.4 » de votre projet, c’est-à-dire que vous avez un `pitch_v2.4.4`, un `synopsis_v2.4.123` et que vous attaquez pour la première fois le scénario, vous numérotez le scénario : `scenario_v2.4`. Noter que dans cette façon de faire, on ne tient pas compte du numéro de patch. L’avantage, c’est qu’il sera facile de retrouver les documents correspondant à une version quelconque (ici la « 2.4 »). Le désavantage, c’est que le numéro de version du document ne sera pas significatif de son développement. Ici, la toute première version du scénario portera le numéro « 2.4 », donc laissera supposer que c’est une seconde version, 4e sous version.

Vous le voyez, aucune solution n’est parfaite.

La meilleure méthode consiste peut-être à adopter une fusion des deux précédentes :

* **Faire un document de chaque type pour chaque version**. Il suffit de bien déterminer ces types, en nombre limité (par exemple « pitch », « synopsis », « scénier », « manuscrit »).
* **Ne tenir compte que du numéro de version majeure pour la correspondance entre les documents**. Cela permet moins de précision mais une souplesse plus grande.
* **Consigner dans un fichier racine les dernières sous-versions de chaque version**, comme nous le verrons ci-dessous.




#### Une mesure de prudence bien pratique

Pour terminer, je ne saurais trop vous suggérer d’avoir, à la racine de votre dossier de développement, un fichier qui pourrait s’appeler « Dernieres-versions.txt ». À l’intérieur de ce fichier, vous pouvez tenir à jour le numéro de dernière version de tous vos documents du projet. Cela permet, notamment pour le manuscrit ou le script final, de toujours bien transmettre la dernière version.

Ce fichier peut ressembler à :

~~~
Pitch : v13.5.247
Synopsis complet : v4.12.300
Scénario : v8.34.199
~~~

Ou, si l’on a adopté la meilleure méthode de numérotation :

~~~
Version 3
	-Pitch : v2.3
	-Synopsis : v2.1.123
	Scénario: v3.45.8
	
Version 2
	Pitch : v2.3
	Synopsis : v2.1.123
	Scénario : v2.67.2
	
Version 1
	Pitch : v1.4.12
	Synopsis : v1.8
~~~



> Noter que l’ordre est inverse, la dernière version est toujours au-dessus.
>
> Noter les « - » qui précèdent certains documents, qui indiquent qu’ils n’ont pas « bougé » de la version précédente. Ils gardent le même numéro.



#### De bonnes habitudes

Une excellente habitude, si l’on veut être sûr de parler du même document avec un lecteur, un co-auteur, un producteur ou autre, est d’être très strict à partir du moment où le document doit « sortir » de son bureau de travail.

C’est le cas par exemple d’un manuscrit ou d’un scénario. Imaginons un… *scénario* pour montrer les bonnes habitudes.

Imaginons que j’aie achevé mon manuscrit de roman et qu’il porte le numéro de la version `v5.2`.

* J’envoie ce document à trois lecteurs A, B et C,

* (je consigne cet envoi dans mon historique — un fichier à la racine de mon projet, où je note toutes mes actions, avec la date et l’heure) :

  ~~~
  HISTORIQUE
  	25/4/2020 - ENVOI v5.2 du scénario à A
  	25/4/2020 - ENVOI v5.2 du scénario à B
  	25/4/2020 - ENVOI v5.2 du scénario à C
  	20/4/2020 - FIN DE LA RELECTURE DE v5.2 du scénario
  	...
  ~~~

* dans mon fichier de dernière version, j’ajoute :

  ~~~
  DERNIÈRES VERSION
  
  Scénario : 5.2
  ~~~

* B me signale une grosse faute dans le titre,

* je duplique la version actuelle pour pouvoir la conserver,

* je corrige la faute dans le nouveau document et j’incrémente son numéro de patch. Le document porte désormais la version `v5.2.2` (pour rappel, la version « v5.2 » est la version complète « v5.2.1 »),

  ~~~
  HISTORIQUE
  	26/4/2020 - Correction (<- B)
  	25/4/2020 - ENVOI v5.2 du scénario à A
  	25/4/2020 - ENVOI v5.2 du scénario à B
  	25/4/2020 - ENVOI v5.2 du scénario à C
  	20/4/2020 - FIN DE LA RELECTURE DE v5.2 du scénario
  	...
  ~~~
* dans mon fichier de dernière version, j’ajoute :

  ~~~
  DERNIÈRES VERSIONS
  
  Scénario : 5.2.2
  ~~~

* je peux à la rigueur envoyer cette nouvelle version, mais ce n’est pas obligé,

* C me signale trois fautes dans le texte,

* je duplique la version actuelle, donc la 5.2.2 et je corrige la duplication,

* j’incrémente la version du document corrigé, ce qui donne `v5.2.3`

* je consigne ce changement dans mon historique, mais ça n’est obligatoire
  ~~~
  HISTORIQUE
  	29/4/2020 - Corrections (<- C)
  	26/4/2020 - Correction (<- B)
  	25/4/2020 - ENVOI v5.2 du scénario à A
  	25/4/2020 - ENVOI v5.2 du scénario à B
  	25/4/2020 - ENVOI v5.2 du scénario à C
  	20/4/2020 - FIN DE LA RELECTURE DE v5.2 du scénario
  	...
  ~~~
* dans mon fichier de dernière version, j’ajoute :

  ~~~
  DERNIÈRES VERSIONS
  
  Scénario : 5.2.3
  ~~~

… et ainsi de suite, avec la certitude que la dernière version — celle qui a le numéro le plus élevé — est toujours la dernière.