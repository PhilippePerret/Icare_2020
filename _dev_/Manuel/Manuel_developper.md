# ATELIER ICARE<br>Manuel développeur



# Introduction

Il s’agit ici de la version produite en 2020 de l’Atelier Icare. Elle vise à simplifier le code au maximum.



<a name="principes"></a>

# Principes fondateurs

* Tout ce qui est après le `/` du domaine et avant le `?` du query-string est appelé `route`. La route brute s’obtient par `Route.current.route`. La seule modification faite est de transformer une chaine vide en `home`.
* Quand une route est définie (par exemple `user/login`) la première chose que fait le programme de construction de la page est de voir si le dossier `./lib/pages/user/login` existe. Si c’est le cas, on le charge, ce qui charge tout ce qui est utile pour l’identification de l’utilisateur, ici. C’est donc dans `lib/pages` principalement qu’on va trouver la définition des pages et c’est vraiment dans ce dossier qu’il faut s’arranger pour tout mettre.
* Si un module ruby de la page ci-dessus définit la méthode `HTML#exec`, cette méthode est appelée avant la fabrication de la page. Cela permet par exemple de traiter les formulaires.
* Les pages ci-dessus surclassent les méthodes générale `HTML#build_header` etc. et principalement la méthode générale `HTML#build_body` qui construit le corps de la page.
* Dès qu’un dossier contient des fichiers `.css` ou `.js`, ils sont automatiquement chargés par la méthode générale `require_module`. « Chargés » signifie que leur balise est insérée dans la page.
* Charger vraiment le minimum de code pour toute section. Donc utilisation intensive de la méthode `require_module` qui va charger à la volée des modules depuis le dossier `./lib/modules`.



## Création d’une nouvelle route/page

Commencer par lire les [principes fondateurs](#principes) du nouveau site.

<a name="dossierroute"></a>

Créer le dossier de la nouvelle route dans `./lib/pages/`. Par exemple, si la route est `user/pourvoir`,  on doit créer le dossier `./lib/pages/user/pourvoir/`. Ce dossier sera  appelé **dossier de la route** dans la suite.

Créer dans ce *dossier de la route*  un fichier `html.rb` (ou autre nom, peu importe) qui contienne :

~~~ruby
class HTML
  
  def titre
    "Le titre de la page"
  end
  
  def exec
    ... code à exécuter avant la construction de la page ...
  end
  
  # Construction du body (section#content)
  def build_body
	  # Mettre ici le code de construction du body de la page
    @body = <<-HTML
			... body de la page ...
		HTML
	end	
end
~~~

Ajouter dans ce dossier les `.css` et les `.js` qui lui sont nécessaires et qui lui sont propres.

Ajouter les vues `ERB` qui peuvent servir à construire l’intégralité du body ou une partie seulement. Cf. [Utilisation des vues ERB](#useerbviews)

### Méthode `exec` à appeler

Comme on peut le voir ci-dessus, la méthode `html#exec` permet d’exécuter un code avant de construire la page. C’est ici, par exemple, qu’on vérifie les valeurs d’identification et qu’on authentifie — ou non — l’utilisateur, etc.

~~~ruby
class HTML
  def exec
    ... code à exécuter avant la fabrication de la page ...
  end
end
~~~



### Les dossiers `xrequired`

Quand on appelle une route, l’application remonte la hiérarchie complète et charge tous les dossiers `xrequired` qu’elle trouve (en général, il n’y en a qu’un seul).

Par exemple, si la route à atteindre est `admin/icariens/outils`, cela fait appel à un dossier se trouvant dans :

~~~
./lib/pages/admin/icariens/outils/
~~~

En appelant cette route, l’application cherche donc à charger les dossiers suivants :

~~~
./lib/pages/admin/icariens/outils/xrequired
./lib/pages/admin/icariens/xrequired
./lib/pages/admin/xrequired
~~~

Cela, on le comprend, permet donc de partager des méthodes et des modules dans un même lieu.

Note : c’est le module `_main_classes/page.rb` qui s’en charge avec la méthode `load_xrequired`.

---

## Messagerie

Pour les messages, on peut utiliser les méthodes suivantes :

### `message("...")` ou `notice("...")`

Pour un message d’information.

### `erreur("...")`

Pour un message d’erreur.

### `log("... »)`, `log(<error>)`, `log({hash})`

Pour un message dans le journal de suivi. Comme le titre l’indique, on peut envoyer indifféremment un string, une erreur ou une table.



### Constantes de messages

On peut trouver dans le fichier `./_lib/required/__first/constants/errors.rb` des constantes de messages d’erreur qui peuvent être appelés par `ERRORS[:<key>]`. On peut trouver de la même manière des messages notice par `MESSAGES[:<key>]`.

Certains messages peuvent même comporter des variables qu’on modifie par :

~~~ruby
erreur( ERRORS[:message_variable] % {var:'première', var2:'deuxième'})

# ou

erreur( ERRORS[:message_vars] % ['première', 'deuxième'])

# Avec :

ERRORS = {
  ...
  message_variable: "Mon %{var} et %{var2}.",
  message_vars: "Mon %s et %s."
 }
~~~





---

## Helpers de formatage



### Constantes LIENS fréquents

#### Liens de retour (pour revenir à une partir principale)

~~~ruby
RETOUR_BUREAU		# Pour retourner au bureau (avec le signe ↩︎ devant)
RETOUR_PROFIL		# Pour retourner au profil (avec le signe ↩︎ devant)
~~~

On peut trouver d’autres liens dans le fichier `./_lib/required/__first/constants/links.rb`.



### Blocs particuliers

Plusieurs méthodes permettent de produire rapidement du code, lorsqu’il est fréquent. C’est le cas des méthodes suivantes.

> De manière générale, on trouve les méthodes helpers dans le dossier `./lib/required/__first/handies` mais il faut comprendre aussi que des méthodes particulières sont définies dans les modules (par exemple les helpers pour les formulaires, dans le module 'forms').



#### `divGoto("... inner ...")`

Pour écrire un lien dans un « bloc » comme ceux qu’on peut trouver sur la page de plan ou sur les accueils de bureau.

![divgoto](divGoto.png)



Quand il y en a plusieurs et qu’on veut en mettre en exergue, on peut ajouter la classe `exergue` de cette façon :

~~~html
<div class="goto exergue">
  ... le contenu ...
</div>
~~~

Avec la méthode divGoto :

~~~ruby
div = divGoto('<inner>', exergue: true)
~~~







#### `StateList.row("libelle", value[, {options}])`

Génère une rangée de type « Statelist » comme on peut en trouver sur la page du travail courant pour afficher l’état du module (nom, échéance)

![stateliste](stateliste-row.png)

**NOTE** : pour que ces rangées s’affichent correctement, il faut entourer le code généré par un  `div.state-list` (ou un `div.state-list.vert` pour un fond vert comme ci-dessus) :

~~~erb
<div class="state-list vert">
  <%= StateList.row("Mon libellé", "Ma valeur", {class:'small'})	
</div>
~~~

> Comme on peut le voir ci-dessus, on peut ajouter un troisième argument qui contiendra des options d’affichage, comme ici la classe à appliquer à la rangée.



Pour **différentes largeurs de libellés**, on peut utiliser les classes `medium` (libellé de taille moyenne) et `large` (libellé large).

Si l’on préfère que les libellés soient **alignés à gauche**, on ajoute la classe `left`.

Ainsi, si on veut une liste avec large libellé alignés à gauche, on utilise :

~~~html
<div class="state-list large left">
  <%= StateList.row("Mon libellé plus large fer à gauche", "une valeur") %>
</div>
~~~



##### Bouton pour modifier les données de la StateList

Si les données contenues dans la **StateList** sont modifiables, on peut ajouter un bouton (crayon pour le moment) qui permet de se rendre au formulaire de modification :

~~~erb
<div class="state-list">
	#{StateList.button_modify('<route>'[, {options}])}
  ...
</div>

~~~

Dans les `{options}`, on peut définir une `:class` supplémentaire ou un `:title` qui apparaitra quand on glisse la souris sur le bouton.





---

## Formulaires

Les formulaires peuvent être facilement créés grâce à la classe `Form`.

Pour instancier le formulaire, il lui suffit d’un identifiant et d’un action (ou d’une route) pour le traitement.

~~~ruby
form = Form.new({id:'...', route:'...', size: ...})
~~~

Par exemple :

~~~ruby
require_module('forms')
form = Form.new(id:'login-form', route:'user/login', size: 300)
# => Instance du formulaire
~~~





On peut définir ensuite les rangées par :

~~~ruby
form.rows = {
  '<Label prop>' => {... définition de la rangée ...},
  '<Label prop>' => {... définition de la rangée ...},
  ...
 }
~~~

Par exemple :

~~~ruby
form.rows = {
  "Votre pseudo" => {name:'user_pseudo', type:'text', value: "Phil"}
  }
~~~

> Note 1 : la propriété `:name` et `:type` sont absolument requises.
>
> Note 2 : la propriété `:value` peut être remplacée par `:default`.



Le nom du **bouton de soumission** du formulaire se définit par :

~~~ruby
form.submit_button = "<nom du bouton>".freeze
~~~

D’**autres boutons**, à gauche de ce bouton, peuvent être définis par :

~~~ruby
form.other_buttons = [
  {text:'<Le texte à afficher>', route: "<route/a/prendre>"},
  ...
  ]
~~~

### Insertion du formulaire

On insère simplement le formulaire à l’aide de :

~~~ruby
form.out
~~~

Par exemple :

~~~ruby
def build_body
  @body = <<-HTML
<p>Le formulaire :</p>
#{form.out}
	HTML
end
~~~



### Traitement du formulaire

On peut traiter le formulaire dans la méthode `exec` appelée en début de traitement de la route. Dans le même [dossier de route][] par exemple. Pour réinstancier ce formulaire, il suffit d’appeler `Form.new` sans argument. C’est automatiquement le formulaire défini dans `param(:form_id)` qui est utilisé. On vérifie si le formulaire est conforme (i.e. s’il n’a pas déjà été soumis) et on le traite. Par exemple :

~~~ruby
class HTML
  def	exec
    if param(:form_id) == 'mon_formulaire' # pour s'assurer que c'est bien lui
      form = Form.new
      if form.conform?
        ... on peut le traiter ici ...
      end
    end
  end #/exec
  
end #/HTML
~~~



### Champ pour les dates

Pour construire un champ avec trois menus pour choisir une date, on peut utiliser la méthode `Form.date_field({<params>})`.

Noter qu’il faut requérir le module 'forms'.

Exemple :

~~~ruby
require_module('forms')

monForm = Form.date_field({prefix_id:'pref', format_mois: :court})
~~~

Pour récupérer la nouvelle date, il suffira de faire :

~~~ruby
require_module('forms')

newDate = Form.date_field_value('pref') 
# => instance Time

message("Le nouveau temps est #{formate_date(newDate)}")
~~~

> cf. la méthode [formate_date][]



<a name="useerbviews"></a>

## Utilisation des vues ERB

Dans la méthode `html#build_body` — ou tout autre module d’un *dossier de route*, peut utiliser très efficacement la méthode générale `deserb` en lui donnant en paramètre la vue à utiliser et la `bindee`.

Par exemple, dans le dossier de la route `user/logout` (`./lib/pages/user/logout/`), on trouve la méthode `build_body`suivante :

~~~ruby
def build_body
  @body = deserb('body', user)
end
~~~

Cette méthode appelle donc la méthode `deserb` en donnant en premier argument `’body’` qui correspond au nom du partiel qui se trouve dans ce même dossier, avec l’extension `.erb` et qui définit le code à utiliser :

~~~html
<div class="only-message">
  À la prochaine, <%= pseudo %> !
</div>
~~~

Comme `user` — donc l’[utilisateur courant][] — est envoyé en second argument, l’utilisateur courant bindera cette vue, donc c’est son `pseudo` qui sera utilisé.

> Noter que cette méthode peut être utilisée pour insérer du code HTML simple, même si ça coûte un peu d’énergie en plus.



<a name="currentuser"></a>

## L'Utilisateur courant

L’utilisateur courant est défini dans `User.current` et peut s’obtenir avec la méthode handy `user`.



## Barrières de sécurité

Les « barrières de sécurité » permettent d’empêcher l’entrée dans certaines pages. Par exemple, un utilisateur non identifié ne peut pas atteindre un bureau, un simple icarien ne peut pas rejoindre une page d’administration.

Pour gérer ces accès, il suffit d’utiliser les méthodes suivantes, par exemple, dans la méthode `HTML#exec` que doit invoquer toute route, quelle qu’elle soit.

~~~ruby
icarien_required			# L'user doit être identifié
admin_required 				# L'user doit être identifié et un administrateur
super_admin_required	# L'user doit être identifié et un super administrateur
~~~

Exemple d’utilisation :

~~~ruby
class HTML
  def exec
    icarien_required
    ... si l'user est identifié, on exécute ce code
		... sinon on raise pour le conduire au formulaire d'identification
  end
  
  ...
end #/HTML
~~~



---

## Méthodes pratiques



<a name="formate_date"></a>

### `formate_date(<date>[, {<options>}])`

Permet de formater une date. Par exemple :

~~~ruby
maintenant = formate_date(Time.now, {mois: :long, duree: true})
# => 28 mai 2020 (aujourd’hui)
~~~

**Options**

~~~
:mois			Format du mois entre :long et :court (3/4 lettres)
:duree		Ajouter la durée, "dans x jours" pour le future, "il y a x jours"
					dans le passé, "aujourd’hui" pour aujourd'hui.
~~~



---



## Classe abstraite `ContainerClass`

C’est la classe qui sert aux modules et étapes, absolus et relatifs, et en général à toute donnée enregistrée dans la base de données, pour fournir les méthodes communes décrites ci-dessous.

Le prérequis pour utiliser ces méthodes est de définir la table :

~~~ruby
class MaClasse < ContainerClass
class << self
  def table ; @table ||= 'ma-table-sql'.freeze end
end # << self
end # /MaClasse
~~~



### `<Classe>::get(item_id)`

Pour pouvoir récupérer une instance quelconque.

> Note : les éléments sont mis dans `@items`.



### `<classe>#data`

Pour atteindre les données enregistrées dans la base de données. Toutes les valeurs étant enregistrées avec des `Symbol`s, on utilise :

~~~ruby
valeur = instance.data[:key_data]
~~~

On peut aussi utiliser la méthode suivante.



### `<classe>#get(:<key>)`

Retourne la valeur pour la clé `<key>`.



### `<classe>#save({h-new-data})`

Pour enregistrer les nouvelles définies dans `{h-new-data}`.



### Autres méthodes

Pour les autres méthodes, cf. le module `./lib/required/__first/ContainerClass.rb`.



## Annexe

### Émojis

Cf. le site [Smiley cool](https://smiley.cool/fr/emoji-list.php).



[utilisateur courant]: #currentuser
[dossier de route]: #dossierroute
[formate_date]: #formate_date