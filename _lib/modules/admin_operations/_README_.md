# Opérations administrateur

## ATTENTION

Contrairement aux autres dossiers du dossier `_lib/modules`, ce dossier ne doit jamais et en aucun cas être chargé par `require_module`. Il contient toutes les opérations administration et ces opérations doivent être appelées individuellement en fonction des besoins.

Il contient également les opérations icariens qui sont appelées en Ajax.


## Création d'un nouvel outil administrateur

* Créer son fichier dans ce dossier.
  Son nom doit correspondre à son utilisation. Pour l'exemple ici, on va créer l'outil `marquer_detruit` qui doit permettre de marquer un utilisateur détruit. On crée donc le fichier `marquer_detruit.rb` dans ce dossier.
* On met en entête le code habituel : `ut[TAB]` pour UTF8 et `frozen[TAB]` pour les frozen-strings.
* On ajoute la méthode d'instance `marquer_detruit` à la class `Admin::Operation`
~~~ruby
class Admin::Operation
  def marquer_detruit

  end #/ marquer_detruit
end #/Admin::Operation
~~~
* Pour l'implémentation proprement dit du code, cf. ci-dessous.
* On ajoute cet outil à la liste de définition du fichier `./_lib/modules/admin_operations/_data_operations_.rb` en définissant les choses utiles.

## Implémentation de la méthode

### Utilise de l'icarien ou des icariens

> Pour le moment, on ne peut pas gérer plusieurs icariens.

Un ou plusieurs icariens peuvent être choisi dans les menus.

Le dernier icarien choisi se trouve dans la propriété `owner`. Par exemple, le code :

~~~ruby
Ajax << {message:"J'ai opéré sur vous, #{owner.pseudo} !"}
~~~

… va afficher ce message avec le pseudo de l'icarien.

### Utilisation des valeurs de champ :

~~~ruby
short_value # valeur du champ short
medium_value # => valeur du champ moyen
long_valur # valeur du champ moyen
select_value # valeur du menu
cb_value # valeur de la case à cocher
~~~

#### Définition de la case à cocher

~~~ruby
  cb_value: {checked:false/true, message:"Le texte de la case à cocher"}
~~~

#### Définition du menu

~~~ruby
  select_value: {
    values: [ ["val item 1", "titre item 1"], ["val item 2", "titre item 2"], ...],
    default: "val item défaut",
    message: "Titre du menu"
  }
~~~

### Pour afficher un message de suivi

### Pour afficher un message ou une erreur

Message normal :

~~~ruby
Ajax << {message: "<le message>"}
~~~

Erreur normale :

~~~ruby
Ajax << {error: "<le message d'erreur>"}
~~~

#### Valeur de la case à cocher

Dans le script ruby de l'outil, `cb_checked` aura la valeur `true` si la case est cochée, `false` dans le cas contraire.

### Outils réservés à l'administration

On peut, à l'avenir, imaginer que certains outils pourront être utilisés par les icariens. Il est donc plus prudent de protéger les méthodes :

~~~ruby
class Admin::Operation
  def mon_outil
    self.admin_required
    # .... le code ici ....
  end
end
~~~
