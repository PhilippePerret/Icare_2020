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
* Pour ne pas se répéter, une table des derniers travaux est enregistrée dans le fichier [./cronjob/data/table_last_works.rb](/Users/philippeperret/Sites/AlwaysData/Icare_2020/cronjob/data/table_last_works.rb).