# Atelier Icare<br/>Manuel du cronjob

## Présentation

Le Cronjob permet d’effectuer des tâches répétitives sur l’atelier, de façon automatique, comme :

* envoyer les mails d’activité quotidienne,
* envoyer les résumés d’activité hebdomadaire,
* nettoyer régulièrement certains dossiers,
* réparer certains problèmes d’incohérence de données patents,
* prévenir l’administration lorsque des erreurs sont survenus à des heures sans surveillance,
* etc.

Pour ce faire, un `crontab -e` a été réglé sur le site distant pour appeler toutes les heures, entre 22 heures et 4 heures du matin, le fichier [./cronjob/cronjob.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/cronjob/cronjob.rb).



## Grands Principes

* Chaque tâche à exécuter s’appelle un `work`. C’est une instance de la class `CJWork` (pour « Cron Job Work » — oui, « Job » et « Work », ça fait un peu redondant, mais tant pis).
* Pour ne pas se répéter, une table des derniers travaux est enregistrée dans le fichier [./cronjob/data/table_last_works.msh](/Users/philippeperret/Sites/AlwaysData/Icare_2020/cronjob/data/table_last_works.msh).



## Travaux

### Définition des travaux

Les travaux se définissent dans le fichier [./cronjob/data/data_works_definition.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/cronjob/data/data_works_definition.rb). La donnée `DATA_WORKS_FIRST_DEFINITION` permet de définir tous les jobs au départ. Voir la [procédure d’ajout de nouveaux travaux](#ajout-travaux) lorsque le cronjob a déjà été joué.

Chaque job définit :

~~~ruby

{
  id: 		String,		# Un identifiant unique, par exemple 'nettoyage_signup_folder'
  every:	Integer,	# Fréquence. Par exemple 10.days (tous les 10 jours), 1.hour (toutes les
  									# heures) etc.
  day:		Integer,  # Le jour où le job doit être effectué (lundi = 1)
  at:			Integer,	# L'heure précise à laquelle il faut effectuer l'opération. Un entier entre
 										# 22 et 4 (22 heures du soir et 4 heures du matin)
  exec:		String,		# Le code à évaluer pour faire le travail. Le plus souvent, une méthode d'objet
  									# définie dans le dossier des modules.
}
~~~



<a name="ajout-travaux"></a>

### Ajout de nouveaux travaux

Quand le cronjob a déjà été joué  (i.e. que le fichier `data_last_work.msh` a été produit), il suffit de définir la donnée `DATA_ADDED_WORKS` dans le fichier [./cronjob/data/data_works_definition.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/cronjob/data/data_works_definition.rb) pour définir les nouveaux jobs à prendre en compte. Ne pas oublier, après la première utilisation, de remettre cette donnée à rien (même si ça n’est pas rédhibitoire puisque les clés ne feront que se remplacer).

Noter qu’on peut aussi ajouter les nouveaux travaux dans ``DATA_WORKS_FIRST_DEFINITION``, mais que toutes les données courantes seront alors perdues (ce qui n’est finalement pas bien grave, entendu que les seules données qui changent sont, pour le moment, la date de dernière exécution).



## Tester

Pour tester le cronjob, on peut simuler une heure en définissant la constante environnement `CRONJOB_TIME` en lançant par exemple dans le Terminal :

~~~bash
cd /path/to/atelier/icare
CRONJOB_TIME='today 10:00' ./cronjob/cronjob.rb

ou

CRONJOB_TIME='19 07 2020 10:00' ./cronjob/cronjob.rb
~~~

Mais si le cronjob a déjà été lancé, il ne sera pas rejoué. Pour forcer le lancement d’un travail même s’il a été lancé dans la journée, ajouter `CRONJOB_FORCE=true` :

~~~bash
CRONJOB_TIME='19 07 2020 10:00' CRONJOB_FORCE=true ./cronjob/cronjob.rb
~~~



### Données pour les tests

On peut obtenir des données pour les tests en jouant la commande `icare feed` et en choisissant par exemple « Actualités » pour ajouter des actualités dans les 20 derniers jours.

La définition des données ajoutées se fait dans le fichier [./\_dev\_/CLI/lib/commands/feed/Actualites.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/_dev_/CLI/lib/commands/feed/Actualites.rb).