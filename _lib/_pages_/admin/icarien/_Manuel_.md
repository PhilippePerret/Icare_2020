# Édition d'un icarien

Cette section `admin/icarien` permet d'éditer un icarien. Dans l'idée, on doit pouvoir, ici, modifier toutes ses informations.

## Modification d'une propriété

* Pour modifier une propriété, on commence par ajouter son champ dans le fichier `vues/icarien.erb` en utilisant la méthode `prop_form`. Si c'est une propriété "directe", c'est-à-dire une propriété que l'icarien possède dans son modèle, il suffit d'utiliser son nom, comme pour `:pseudo` ou `:icmodule_id`. En revanche, si c'est une autre propriété comme le nom du projet — qui est une propriété de son icmodule courant —, il faut s'y prendre autrement :
  * on définit un nom pertinent, par exemple `:project_name` pour le nom du projet ;
  * dans le fichier [`lib/constants`][], dans la constant `DATA_PROPS` qui définit les propriétés, on ajoute une ligne pour la propriété avec les bonnes propriétés ([voir le détail des propriétés](#define-property)). Ici, le type est `String`, on a juste besoin d'un champ de texte pour éditer la propriété, donc on met :

  ~~~ruby
  DATA_PROPS = {
    ...
    project_name: {type:'text'}
  }
  ~~~

  Cela produit le champ text pour notre formulaire d'édition :

  ![Champ de texte pour la propriété project_name](img/champ-nom-projet.jpg)

  À ce point, si le titre est défini, il n'est pas renseigné dans le champ. De la même manière, si l'on définit le titre dans le champ et que l'on clique le bouton « Changer », le titre ne sera pas enregistré. Il faut définir les méthodes qui vont permettre de le faire.

  * Pour pouvoir récupérer la valeur, on crée une méthode d'instance de `User` dans [`lib/user.rb`][], qui porte le nom de la propriété. Évidemment, cette méthode doit retourner la valeur de la propriété :

  ~~~ruby
  class User
    ...
    def project_name
      @projet_name ||= icmodule.project_name
    end
  end #/User
  ~~~

  * Pour pouvoir enregistrer la valeur avec le bouton « Change », on a deux solutions :
    * une méthode `User#set_<property>` (par exemple `User#set_project_name`)
    * une méthode `User#<property>=` (par exemple `User#project_name=`)

    Les deux méthodes sont à mettre dans le module [`lib/user.rb`][].


<a name="define-property"></a>

## Définition de la propriété

Les propriétés à éditer se définissent dans la constantes `DATA_PROPS` dans le fichier [`lib/constants`][]. Chaque ligne présente une propriété.

Si c'est **une propriété de texte simple**, comme un pseudo, une adresse email ou un titre de projet, il suffit d'ajouter le nom de la propriété en clé et une table définissant seulement le type `type: 'text'` :

~~~ruby
DATA_PROPS = {
  ...
  ma_property: {type: 'text'}
}
~~~

Si **la valeur finale doit être convertie** (castée) dans un autre type, on l'indique dans la propriété `vtype`. Pour le moment, on a les types `integer` — qui transforme la valeur en nombre — et le type `symbol` qui transforme en `Symbol`.

Si de nouveaux *vtypes* doivent être définis, il faut implémenter leur traitement dans la méthode `HTML#save_property` du module [`html.rb`][].

### Choix dans une liste

Si la valeur doit être choisie dans une liste de valeurs proprosées, comme pour le statut de l'icarien, on définit la propriété `options` qui devra définir la méthode ou la propriété d'instance de class `HTML` qui va retourner les `OPTIONS` du menu qui sera implémenté. On peut l'implémenter dans [`lib/html_helpers.rb`][] par exemple.

### Objet éditable/visualisable

Il est possible qu'une propriété, comme `icmodule_id` par exemple, fasse référence à un objet complexe, comme un `IcModule` ici. Dans ce cas, on peut ajouter `editable:true` à la définition de la propriété pour voir ajouter un bouton « Voir » qui permettra de voir ou d'éditer l'objet en question.

*Pour que ça fonctionne*, il faut OBLIGATOIREMENT que la propriété se termine par `_id` et que la propriété, de vtype `integer`, définisse un identifiant d'objet.

Il faut ensuite qu'une vue existe, dans le dossier `./vues`, qui porte le nom de la propriété sans son `_id`. Par exemple `./vues/icmodule.erb` pour la propriété `:icmodule_id`. Cette vue doit bien sûr définir comment sera affiché l'objet.


[`html.rb`]: /Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/pages/admin/icarien/html.rb
[`lib/html_helpers.rb`]: /Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/pages/admin/icarien/lib/html_helpers.rb
[`lib/constants`]: /Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/pages/admin/icarien/lib/constants.rb
[`lib/user.rb`]: /Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/pages/admin/icarien/lib/user.rb
