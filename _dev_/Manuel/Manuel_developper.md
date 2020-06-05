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

> Il existe un script pratique, à `./_dev_/CLI/scrip/create_route.rb` qui permet de créer une route très facilement et efficacement.

**Attention** : une route ne doit pas être créée dans une autre, puisque tout le dossier d’une route est entièrement chargé, ruby, css, javascript quand elle est appelée (donc le dossier de l’autre route à l’intérieur serait lui chargé…).

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

Le chargement des routes respecte le [principe des xrequired][]

---

<a name="principes"></a>

## Principes

<a name="principexrequired"></a>

### Principe des xrequired

Le « principe des xrequired » signifie que lorsqu’on charge un dossier (à l’aide de la méthode `require_module` ou `Page.load`), tous les dossiers `xrequired` se trouvant sur la hiérarchie sont automatiquement chargés. Cela permet d’hériter de méthodes supérieures. Pour les [watchers](#leswatchers), cela permet d’hériter des méthodes utiles lorsqu’un watcher est actionné.

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

> Note : pour les routes, c’est le module [`./_lib/_classes/page.rb` ](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/required/_classes/page.rb) qui s’en charge avec la méthode `load_xrequired`. Pour les modules, c’est la méthode `load_xrequired_on_hierarchy` du module [./_lib/required/__first/require_methods.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/required/__first/require_methods.rb).



---



## Requérir des modules à la volée

Requérir des modules à la volée permet de ne charger que le code nécessaire à une section. C’est un principe fondateur du nouvel atelier.

On les charge à l’aide des méthodes :

~~~ruby
require_module('nom-module')

require_modules(['module1', 'module2', ..., 'moduleN'])
~~~



Requérir un module signifie :

* requérir tous ses fichiers ruby (`.rb`), dans son dossier ou ses sous-dossiers,
* charger les feuilles de styles (`.css`) de son dossier et ses sous-dossiers,
* charger les javascripts (`.js`) de son dossier et tous ses sous-dossiers,
* requérir tous les éléments des dossiers `xrequired` de ses ascendants selon le [principe des xrequired][].



Ces modules doivent se trouve dans le dossier :

~~~bash
./_lib/modules/
~~~





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

## Construction des pages, helpers



### Titre de la page

Le titre de la page est défini par la méthode `HTML#titre`.

Quand le titre doit être « détaché » du bandeau de log et du contenu de la page — comme cela arrive avec le hall of fame par exemple, on peut utiliser la constante `DIV_AIR` pour ajouter de l’air.

Par exemple :

~~~ruby
class HTML
  def titre
    @titre ||= "#{DIV_AIR}Mon beau titre#{DIV_AIR}".freeze
  end
  ...
end #/HTML
~~~



### `Tag`, builder de balises

La classe `Tag`, définies dans [./_lib/required/__first/helpers/Tags.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/required/__first/helpers/Tags.rb), permet de créer très facilement des liens à l’aide de la méthode :

~~~ruby
Tag.<type tage>({<params>})
~~~

Par exemple :

~~~ruby
lien = Tag.link({route:"ma/route", titre:"Suivre ma route", class:'class-du-lien'})
~~~

Voir dans le fichier ci-dessus toutes les méthodes utilisables.



### Constantes LIENS fréquents



#### Liens de retour (pour revenir à une partir principale)

~~~ruby
RETOUR_BUREAU		# Pour retourner au bureau (avec le signe ↩︎ devant)
RETOUR_PROFIL		# Pour retourner au profil (avec le signe ↩︎ devant)
~~~



#### Lien vers le bureau

~~~ruby
Tag.lien_bureau([titre])
# Note : il vaut mieux ne pas utiliser `[titre]` pour avoir un picto avec "Bureau"
~~~



#### Lien vers des routes connues

On peut obtenir des liens vers des routes connues grâce à la méthode `Tag.route`, en passant en premier argument soit un raccourci de route (par exemple `:aide` pour l’aide) soit une route explicite.

Les raccourcis de route sont définis dans le fichier [./_lib/required/__first/constants/routes.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/required/__first/constants/routes.rb).

On utilise alors :

~~~ruby
Tag.route(:<route id>[, "titre", {options}])
~~~

> Dans `options`, on peut par exemple indiquer `full: true` pour créer un URL entière qui pourra être utilisée dans les mails.
>
> Noter que c’est le cas, de manière générale, avec toutes les méthodes générant des liens, à commencer par `Tag.lien`.



#### Lien « retour » pour titre

Pour définir un lien à ajouter au titre des pages, ressemblant à :



… on utilise la méthode :

~~~ruby
Tag.retour(:route, :titre)
# Les deux arguments sont obligatoire
~~~



<a name="specsblocks"></a>

### Blocs particuliers

Plusieurs méthodes permettent de produire rapidement du code, lorsqu’il est fréquent. C’est le cas des méthodes suivantes.

> De manière générale, on trouve les méthodes helpers dans le dossier `./lib/required/__first/handies` mais il faut comprendre aussi que des méthodes particulières sont définies dans les modules (par exemple les helpers pour les formulaires, dans le module 'forms').



#### Les div boutons (buttons)

~~~ruby
<div class="buttons">
</div>
~~~

Ils sont toujours formatés en respectant les règles suivantes :

* ils ont le fer à droite,
* ils laissent de l’air au-dessus de leur tête,
* traitent tous les liens `<a>` comme des boutons (class `btn`),
* traitent tous les liens `<a class="main">` comme des boutons principaux.

<a name="blocgoto"></a>

#### Les blocs « GoTo »

~~~ruby
divGoto("... inner ...")
~~~

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



#### Les « listes d'état » (StateList)

~~~ruby
StateList.row("libelle", value[, {options}])
~~~

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



## Styles particuliers



### Outils discrets

Les outils discrets sont des boutons qui ont une faible opacité et qui s’affiche normalement lorsque l’on glisse la souris dessus. Ils sont obtenus à l’aide de la classe CSS `discret-tool`.

~~~html
<div class="boutons discret-tool tiny">
  <button>Mon bouton</button>
  <a href="#justeque">Pour voir</a>
</div>
~~~





---

## Formulaires

Les formulaires peuvent être facilement créés grâce à la classe `Form`.

Pour instancier le formulaire, il lui suffit d’un identifiant et d’un action (ou d’une route) pour le traitement.

~~~ruby
form = Form.new({id:'...', route:'...', size: ...})
~~~

Par exemple :

~~~ruby
require_module('form')
form = Form.new(id:'login-form', route:'user/login', size: 300)
# => Instance du formulaire
~~~

**Propriétés obligatoires**

~~~ruby
{
  id: 'identifiant du formulaire',
  route: 'route/pour/la/soumission'
 }
~~~



**Propriétés optionnelles** définissables :

~~~ruby
{
  size: 800, 					# largeur totale du formulaire
  libelle_size: 100, 	# largeur des libellés (pour les réduire, souvent)
	class: 'classCSS'		# Class CSS du formulaire  
  										# Par exemple 'noborder' pour retirer le cadre du formulaire
}
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



### Types de champ

~~~
text					Pour un input text simple
textarea			Pour un champ textarea
password			Pour un mot de passe
select				Pour un menu select. Les valeurs doivent être fournies par :values
checkbox			Une case à cocher
file					Pour choisir un fichier
raw						Pour un code qui sera inséré tel quel (par exemple une liste de cbs)
titre					Un titre (le label est le titre)
explication		Une explication discrète pour un champ. Mettre un label unique mais quelconque

~~~

#### Définition d'un menu

~~~ruby
form.rows = {
	  ...
    'MonChoix' => {type:'select', name:'uchoix', values: [[1,"Un"], [2,"Deux"]]}
  }
~~~

En `values`, on peut aussi mettre une liste simple, quand les valeurs sont égales aux titres à afficher.



### Champ pour les dates

Pour construire un champ avec trois menus pour choisir une date, on peut utiliser la méthode `Form.date_field({<params>})`.

Noter qu’il faut requérir le module 'forms'.

Exemple :

~~~ruby
require_module('form')

monForm = Form.date_field({prefix_id:'pref', format_mois: :court})
~~~

Pour récupérer la nouvelle date, il suffira de faire :

~~~ruby
require_module('form')

newDate = Form.date_field_value('pref') 
# => instance Time

message("Le nouveau temps est #{formate_date(newDate)}")
~~~

> cf. la méthode [formate_date][]



<a name="tdm-de-page"></a>

## Table des matières de page (flottante)

On peut faire une table des matières flottante dans la page à l’aide de la class `FloatTdm`.

~~~ruby
tdm = FloatTdm.new(liens[, {options}])
tdm.out
# => la table des matières mis en forme
~~~

Les liens doivent être définis par :

~~~ruby
liens = [
  {route:'la/route', titre:'Le titre'[, class:'css']}
]
~~~

Si la route courante correspond à la route d’un item, cet item est mis en courant, donc atténué.

Par défaut, la table des matières flotte à droite. Pour la faire flotter à gauche, ajouter `left: true` dans les options envoyés en second argument.

**Options**

~~~ruby
:titre			{String}			# Si fourni, ce titre est ajouté, un peu comme dans un fieldset
:left				{Boolean}			# si true, la table des flottante à gauche.
~~~



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



<a name="leswatchers"></a>

## Les Watchers



Les watchers permettent de gérer toute l’activité, les actions, possible sur l’atelier. Ils permettent de produire les notifications qui doivent être données à l’administrateur ou à l’icarien/utilisateur.

Les **données de tous les watchers** sont définies dans le fichier [_lib/modules/watchers/constants.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/modules/watchers/constants.rb).

Le principe est le suivant :

* Un watcher est créé (par exemple à l’inscription d’un candidat à l'atelier)
* Ce watcher, s’il définit un fichier `notification_admin.erb`, produit une nouvelle notification sur le bureau de l’administrateur,
* s’il définit un fichier `notification_user.erb`, produit une nouvelle notification sur le bureau de l’icarien·ne concerné·e,
* Cette notification contient un bouton qui permet toujours de jouer (runner) ce watcher (ou de le « contre-runner »).
* Runner le watcher crée les opérations nécessaires dans les données concernées.
* Si le watcher définit un fichier `mail_admin.erb` alors ce mail est automatiquement envoyé à l’administrateur.
* Si le watcher définit un fichier `mail_user.erb` alors ce mail est automatiquement envoyé à l’icarien·ne concerné·e.
* Si le watcher définit un fichier `actualite.erb` alors cette actualité est ajoutée aux actualités du site.
* Le watcher est détruit, ce qui retirera automatiquement les notifications des icariens et administrateur.



### Constitution des données de watchers

Les données des watchers, enregistrées dans la table `watchers` définissent :

~~~ruby
{
	wtype:  'commande_module',# Le type du watcher. Ce type permet de retrouver ses données
  													# absolues dans DATA_WATCHERS
  objet_id:	12,							# Identifiant de l'objet. On utilise donc 
  													# objet.get(objet_id) pour obtenir l'objet. Ici un module
  user_id: 2								# Identifiant de l'icarien visé par le watcher
  vu_admin: true						# Pour définir si l'administrateur a vu ce watcher
  vu_user:  false						# Pour déterminer si le user a vu ce watcher
  triggered_at: nil,				# Permet de définir la date où le watcher doit être activé, 
  													# c'est-à-dire où il doit produire une notification.
  data: nil,								# Éventuellement un Hash jsonné contenant les données utiles.
}
~~~



### Visualisation (vu_)

Le données `vu_admin` et `vu_user` sont déterminées à la création du watcher en fonction du fait que c’est l’administrateur ou l’icarien qui génère (ou crée) le watcher. En fait, on pourrait aussi mettre ça dans les données absolues du watcher, mais ça fonctionne très bien comme ça (pour le moment) et ça simplifie la définition des données absolues.



### Ajout d’un watcher à un icarien

Pour ajouter un watcher à un icarien, il suffit d’appeler la méthode :

~~~ruby
require_module('watchers') # requis

icarien.watchers.add(<watcher type>, {<data>} )
~~~

Les `types de watchers` sont définis dans le fichier [_lib/modules/watchers/constants.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/modules/watchers/constants.rb).

Les données qui seront enregistrées dans la table `watchers` sont les suivantes, beaucoup sont automatiques ou semi-automatiques :

~~~ruby
data = {
	objet_id:				Integer,		# toujours requis. C'est la donnée par exemple, qui 
  														# définit l'objet à traiter.
	triggered_at:		Integer,		# Si le watcher ne doit être déclenché qu'à un temps
  														# donné, comme les paiements.
  params:					Hash/String	# Un Hash (table) de données à transmettre. Il sera
  														# jsonné pour être gardé dans la table.
  # = SEMI-AUTOMATIQUE =
  vu_admin:				Boolean,		# Automatique (en fonction du créateur du watcher) mais peut
  														# être défini explicitement lorsqu'un watcher n'a pas à être
  														# vu par l'administrateur
  vu_user:				Boolean,		# Automatique (en fonction du créateur du watcher) mais peut
  														# être défini explicitement lorsqu'un watcher n'a pas à être
  														# vu par l'user
	
  # = AUTOMATIQUE = 	
  user_id:				Integer,		# Définit automatiquement (possesseur du watcher)
	wtype:					String			# Pris du premier argument
}
~~~





### Lancement d’un watcher

Noter que le dossier [./_lib/modules/watchers_processus/xrequired](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/modules/watchers_processus/xrequired), conformément au [principe des xrequired](#principexrequired), est automatiquement chargé dès qu’un watcher est actionné.



### Création d’un nouveau watcher

Il suffit de définir ses données dans le fichier `watcher/constants.rb` vu plus haut.

Ensuite, on crée le dossier :

~~~
_lib/modules/watchers_processus/<objet-class>/<processus>/
~~~

… et on met dedans tous les fichiers utiles. 

À commencer par le fichier `main.rb` qui doit définir :

~~~ruby
class Watcher < ContainerClass        class Watcher < ContainerClass
  # Methode appelée quand on runne le watcher
  def <processus>												def start
    ...																		...
  end 																	end
  
  # Méthode optionnelle appelée quand on refuse le watcher
  def contre_<processus>								def contre_start
    ...																		...
  end																		end
end #/<objet>													end #/IcModule
~~~

Dans ces méthodes, on a accès à toutes les propriétés du watcher, à commencer par :

~~~ruby
owner				# {User} Propriétaire du watcher, l'icarien visé
objet				# l'instance de l'objet visé, par exemple un IcModule d'icarien
objet_id		# l'identifiant de l'objet visé
processus		# Le "processus", donc la méthode
params			# Les paramètres éventuellements transmis
~~~



Il faut ensuite faire ses notifications, en fonction de ce qui doit être affiché à l’administrateur et l’user.

~~~
Dans ./_lib/modules/watchers_processus/<objet>/<processu>/
						main.rb  									# cf. ci-dessus
						notification_admin.erb		# si l'administrateur doit être notifié
						notification_user.erb			# si l'icarien doit être notifié
						mail_admin.erb						# si l'administrateur doit recevoir un mail à run
						main_user.erb							# si l'icarien doit recevoir un mail au run
						actualite.erb							# si une actualité doit être produite au moment où
																			# le watcher est runné
~~~



### Construction des notifications

Les « notifications » sont des fichiers `ERB` adressés soit à l’administrateur soit à l’icarien. Ils portent les noms :

~~~
notification_admin.erb		# pour l'administrateur
notification_user.erb			# pour l'icarien
~~~

Dans ces fichiers, on doit utiliser un `div.buttons` pour placer les boutons principaux.

~~~erb
<div class="buttons">
  <%= button_unrun("Renoncer") %>
  <%= button_run("Jouer la notification") %>
</div>
~~~



Si un formulaire doit être utilisé pour la notification — ce qui est souvent le cas — on doit utiliser cette tournure :

~~~ruby
<%
  form = Form.new(..., class:'inline')
	form.rows = {
    '<watcher>' 	=> {type:'hidden', name:'wid', value:id},
    '<operation>' => {type:'hidden', name:'ope', value:'run'}
  	... les autres champs utiles ...
  }
	form.submit_button = "Activer ce watcher"
	form.other_buttons = [
    btn_unrun("Renoncer et détruire")
  ]
%>

<%= form.out %>
~~~



#### Destruction ou édition d’un watcher

Quand c’est une notification administrateur, les boutons pour forcer la destruction et éditer la notification sont automatiquement ajoutés à chaque notification.



### Méthodes d’helpers pour les notifications

~~~erb
<%= button_run('Titre bouton') %>
  # => bouton principal pour jouer le watcher

<%= button_unrun('Renoncer') %>
	# => bouton secondaire pour "contre-jouer" le watcher (refuser)
~~~



### Construction des mails

Les mails sont des fichiers `ERB` adressés à l’administration ou à l’icarien. Noter qu’ils sont envoyés APRÈS avoir joué le processus avec succès. Comme pour les notifications, c’est la présence ou non de ces fichiers qui détermine s’il faut envoyer ou non un mail après exécution du watcher.

~~~
mail_admin.erb			# mail à envoyer à l'administrateur 
mail_user.erb				# mail à envoyer à l'icarien

contre_mail_admin.erb # mail à envoyer à l'administrateur en cas de renoncer (bouton contraire)
contre_mail_user.erb  # mail à envoyer à l'icarien en cas de contre-processus
											# Par exemple, pour la commande d'un module, ce mail est envoyé quand
											# je refuse d'attribuer ce module.
~~~

C’est le watcher lui-même qui est *bindé* à la vue, donc pour obtenir l’user concerné dans les messages, on peut utiliser :

~~~erb
<p>Bonjour <%= owner.pseudo %> !</p>
~~~



### Méthodes d’helpers pour les mails

> Note : toutes ces méthodes sont définies dans le fichier [_lib/modules/watchers/Watcher/helpers.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/modules/watchers/Watcher/helpers.rb).

~~~erb
<%= votre_bureau %>      # insert un lien pour rejoindre son bureau depuis le mail

<%= contacter_phil %>    # insert un "contacter Phil" dans le mail (avec le lien)

<%= faq_de_latelier %>   	# insert "Foire Aux Questions de l'atelier" dans un mail (avec
													# le lien)
~~~



### Construction de l'actualité

L’actualité se définit dans le fichier `actualite.erb` du dossier du watcher. Ce fichier doit définir seulement un `span` qui contient le message d’actualité à enregistrer.

Le watcher est bindé à ce fichier `ERB`.

Par exemple :

~~~erb
<span>
	<%= owner.pseudo %> produit une actualité avec <%= objet.ref %>.
</span>
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



### `<classe>::collect([filtre])`

Permet de collecter sur tous les éléments (chargés de la base de données, donc consommateur).

Le filtre optionnel est un `String` définissant la clause WHERE. Par exemple :

~~~ruby
AbsModule.collect("name LIKE 'S%'") do |absmodule|
  # On peut travailler sur absmodule, l'instance AbsModule
  # retenue
  ...
end
~~~



### `<classe>::each([filtre])`

Même chose que pour `collect` ci-dessus, mais sans retourner de résultat.

Par exemple :

~~~ruby
Watcher.each("user_id = 1") do |watcher|
  puts watcher.out
end
~~~

> Note : c’est juste un exemple car la classe `Watcher`, à l’heure d’aujourd’hui, n’est pas un ContainerClass.

### `<classe>::each_with_index([filtre])`

Même chose que pour `each` ci-dessus, mais avec l'index en deuxième paramètres.

Par exemple :

~~~ruby
AbsModule.each_with_index("user_id = 1") do |mod, idx|
  puts "Module d'index #{idx}"
end
~~~




### `<classe>::get_all([filtre][, <reset true|false>])`

Permet de charger tout ou partie des données, en les mettant dans la variable `@items`. On peut donc ensuite utiliser `get(id)` pour obtenir l’instance.

Cette méthode est à utiliser lorsqu’on sait qu’il va y avoir un grand nombre d’instance à instances.

Si on met en second argument `true`, alors la variable `@items` est remise à rien et on peut ensuite utiliser `<classe>::each_item` pour boucler sur tous les items retenus. 

Par exemple, pour afficher tous les modules suivis par un icarien, on peut faire :

~~~ruby
IcModule.get_all("user_id = #{icarien.id}")
IcModule.each_item do |icmodule|
  puts icmodule.out
end
~~~

> Noter que le code précédent revient à utiliser `IcModule.each("user_id = #{icarien.id}") do ...`



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



---

<a name="download"></a>

## Téléchargement

Pour permettre le téléchargement, on utilise la classe `Downloader` qui permet de gérer très facilement ces téléchargements.

Il suffit d’utiliser la méthode handy `download` :

~~~ruby
download("<path>"[, "<nom fichier zip>"[, <options>]])
~~~

Les options permettent de définir :

~~~ruby
options = {
  keep: true, 		# ne détruit pas le dossier original à la fin
}
~~~



Elle fait :

~~~ruby
require_module('download')

downloader = Downloader.new([liste documents], "<nom fichier zip>")
downLoader.download
~~~

That’s it! Les documents seront proposés au téléchargement.

**Fonctionnement**

La classe `Downloader` créer un fichier zip dans le dossier `./tmp/downloads/` . Ce fichier zip est détruit tout de suite après le téléchargement du zip.



---



## Test de l'application



### Tester les mails



#### Vider le dossier mail

~~~ruby
vide_dossier_mails
~~~

Cela vide le dossier `./tmp/mails` dans lequel sont enregistrés les codes html de tous les mails envoyés, en offline comme en online.




#### Tester si un mail contenant un certain texte a été envoyé

~~~ruby
TMails.exists?(<dest.>, <cherché>[,<options>])			TMails.exists?("phil@chez.moi", "Bonjour Phil !")
~~~



#### Récupérer tous les mails d’un certain utilisateur

~~~ruby
TMails.for(<mail destinataire>[,<options>])							TMails.for("phil@chez.moi")
# => Liste d'instance TMail
~~~

<a name="classtmail"></a>

Cette méthode retourne donc une liste d’instance `TMail` qui répond aux méthodes suivantes :

~~~ruby
tmail.contains?(str)		# retourne true si contient le texte +str+
tmail.content						# le contenu textuel du mail
tmail.time							# Le temps de l'envoi
tmail.destinataire			# le destinataire de l'envoi
tmail.expediteur				# l'expéditeur de l'envoi
tmail.filename					# le nom du fichier
~~~



<a name="optionsmails"></a>

#### Options pour les méthodes de mail

Ces options permettent de définir plus finement les recherches, les filtres qui doivent être appliqué à la relève des mails. Par exemple `TMails.find`, `TMails.exists?`, etc.

Toutes ces options sont… optionnelles

~~~ruby
options = {
	from:		'<mail expéditeur>',   	# auto explicatif
  after:	Time,										# le mail doit avoir été envoyé après ce temps
  before:	Time,										# le mail doit avoir été envoyé avant ce temps
}
~~~





---



## Annexe


### Paramètres URL

Pour voir les paramètres, on peut utiliser `URL.current.params` qui retourne une table avec les paramètres de l'url.

Par exemple pour les mettre dans le fichier journal.log :

~~~ruby
log("params: #{URL.current.params.inspect}")
~~~


### Émojis

Cf. le site [Smiley cool](https://smiley.cool/fr/emoji-list.php).



## NOTES



### [Note 001]









[utilisateur courant]: #currentuser
[dossier de route]: #dossierroute
[]: 
[formate_date]: #formate_date
[principe des xrequired]: #principexrequired