# Concours<br>Manuel d'utilisation

# Étape du concours

L'étape courante du concours détermine là où on se trouve du concours. Elle est maintenue par la propriété `step` dans la base de données

| step | Description                |          | Note                                                         |
| ---- | -------------------------- | -------- | ------------------------------------------------------------ |
| 0    | Concours en attente        | *état*   | Le concours est en attente, rien n’est affiché.<br />Un visiteur quelconque peut s’inscrire (notamment pour être averti) |
|      |                            | *action* | Déterminer le prochain thème.<br />Composer le jury.         |
| 1    | Le concours est en cours   | *état*   | Un visiteur peut s’inscrire, un visiteur peut transmettre son synopsis.<br />Un évaluateur peut commencer à lire le synopsis et l’évaluer.<br />Le concours est annoncé sur l’atelier.<br />Le thème est déterminé, le concurrent peut commencer à écrire. |
|      |                            | *action* | Les concurrents sont avertis du lancement du concours.       |
| 2    | Échéance                   | *état*   | Un visiteur peut toujours s’inscrire, mais pour la session suivante (avertissement).<br />Un concurrent ne peut plus transmettre de document.<br />Un évaluateur peut toujours lire et évaluer le synopsis.<br />L’administrateur ne peut pas produire les fiches de lecture (officiellement) ni afficher les résultats. |
|      |                            | *action* | Un mail est envoyé aux concurrents pour annoncer la fin de l’échéance et décrire un peu la suite (sélection). |
| 3    | Première sélection         | *état*   | Les synopsis sont sélectionnés pour la sélection finale.<br />Un mail annonce aux perdants qu’ils n’ont pas été retenus.<br />Un mail annonce aux gagnants du premier tour qu’ils ont été retenus. |
|      |                            | *action* | Mail envoyé aux concurrents pour annonce de la première sélection |
| 5    | Palmarès                   | *état*   | L’administrateur peut afficher les résultats, produire les fiches de lectures, informer les concurrents des résultats.<br />Les concurrents peuvent consulter leurs résultats sur leur espace.<br />Un visiteur quelconque peut toujours s’inscrire, mais pour la session suivante (avertissement). |
|      |                            | *action* | Mail d’annonce des résultats aux concurrents                 |
| 8    | Fin officielle du concours | *état*   | Le concours n’est plus annoncé sur l’atelier.                |
|      |                            | *action* | Mail de fin de concours, remerciements aux concurrents, annonce de la prochaine session.<br />Remerciements aux membres du jury. |
| 9    | Concours nettoyé           | *état*   | Les éléments du concours sont nettoyés pour permettre le lancement et le traitement du prochain concours. |



### Opérations pour chaque étape

On peut définir les opérations et les informations à donner à chaque passage d’étape dans le fichier [steps_data](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/_pages_/concours/admin/lib/steps_data.rb). On trouve par exemple :

~~~ruby
STEPS_DATA = {
  ...
  5 => {name:"Le nom commun", name_current:"Nom quand étape courante", name_done:"Nom quand achevée"
    operations: [
    	{name:"Nom de l'opération qui doit jouer la méthode :method", method: :ma_methode_de_cinq}, # (1)
      {name:"Nom de l'information à afficher", info: true}, # (2)
    ]
    }
  }
~~~



(1) Pour définir une méthode à jouer lorsque l'on passe à cette étape. Cette méthode doit être définie (avec argument `options`) dans le fichier `concours/xmodules/admin/operations/step_operations/step_X.rb` ([step_5.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/_pages_/concours/xmodules/admin/operations/step_operations/step_5.rb) pour l’étape 5).

(2) Pour définir une ligne informative qui donnera juste une information, par exemple en disant ce que ce passage à l’étape va entrainer comme changement sur l’espace personnel des concurrents, sur la page d’accueil, etc.



## Envoi de mailing

L’envoi de mails est facilité pour le concours (le fonctionnement doit d’ailleurs être repris sur le site [Note du 25 octobre 2020]).

Pour commencer, tous les mails sont écrits dans le dossier :

~~~bash
./_lib/_pages_/concours/xmodules/mails
~~~

Ensuite, une classe intermédiaire `MailSender` se charge de l’envoi en nombre, il suffit de lui envoyer la liste des destinataires, le nom du mail dans le dossier ci-dessus et quelques options (pour préciser par exemple qu’il ne faut pas envoyer vraiment le mail mais seulement simuler la commande — mode `:noop`).

~~~ruby
MailSender.send([destinataires], "nom_mail", {options})
~~~

Avec :

~~~ruby
destinataires = [
  {pseudo: "pseudo", mail: "mail"[, autre_data: "facultatif"]},
  idem, idem, idem
 ]

nom_mail = "nom_du_fichier_dans_dossier_mails"

options = {
  noop: true,				# Simuler seulement si TRUE
  doit: true,				# Confirmation qu'il faut le faire si TRUE et si :noop est false
}
~~~

#### Titre du mail

C’est ici que la démarche est largement simplement : dans le mail (i.e. dans le fichier ERB), il suffit d’utiliser la méthode `subject("Titre du mail")` pour définir le `subject` du mail. De cette manière, message du mail et sujet du mail sont toujours associés.

#### Contenu du mail

Dans le mail, on utilise deux sortes de variables :

* Les variables ERB (`<%= ... %>`) qui seront renseignées au déserbage,
* Les variables template ruby (`%{…}`) qui seront évaluées au moment de l’envoi, avec les données des destinataires. À commencer par le pseudo.

~~~ERB
<p>
  Bonjours %{pseudo},
</p>
<p>
  Nous sommes cette année en <%= Time.now.year %> et votre mail est %{mail}.
</p>
<%= signature %>
~~~



## Résultats (messages)

Dès qu’il faut produire un résultat en plusieurs lignes, qui s’étend sur plusieurs méthodes, on peut utiliser `html.res <<` (ou simplement `res << ` dans une méthode d’instance de la classe `HTML`). Dans la page, il suffit ensuite d’utiliser `<%= resultat %>` (si l’instance `HTML` est bindée) ou `<%= html.resultat %>` (dans le cas contraire) pour afficher ce résultat et le réinitialiser.

#### Ajout d’un message de résultat

~~~ruby
html.res << "Mon message de résultat"
~~~

#### Affichage du résultat

~~~erb
<%= resultat %>

<%= html.resultat %>
~~~

