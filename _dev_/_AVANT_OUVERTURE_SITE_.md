#


* Changer les colonnes `absmodule_id` et `absetape_id` de la table `icdocuments`

  ~~~SQL
  ALTER TABLE `icdocuments` CHANGE `absmodule_id` `absmodule_id` INT(2) DEFAULT NULL;
  ALTER TABLE `icdocuments` CHANGE `absetape_id` `absetape_id` INT(11) DEFAULT NULL;
  ~~~

* Ajouter les colonnes `vu` dans les tables :

  ~~~SQL
  ALTER TABLE `watchers` ADD COLUMN `vu_admin` BOOL DEFAULT false AFTER `data`;
  ALTER TABLE `watchers` ADD COLUMN `vu_user` BOOL DEFAULT false AFTER `vu_admin`;
  ~~~

* Modifier les icariens suivants:

  ~~~SQL
  ~~~
