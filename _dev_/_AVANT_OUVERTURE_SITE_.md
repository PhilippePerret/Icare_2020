#

* Récupérer toutes les données SQL actuelles de l'atelier online

* Modifier ces données, en transformant par exemple `abs_module_id` et `abs_etape_id` en `absmodule_id` et `absetape_id`

* Modifier la table des tickets

  ~~~SQL
  ALTER TABLE tickets MODIFY COLUMN `id` INTEGER(11) AUTO_INCREMENT;
  ~~~

* Voir les colonnes qui ont été supprimées

* Changer les colonnes `abs_module_id` et `abs_etape_id` de la table `icdocuments` et de la table `icmodules`

  ~~~SQL
  ALTER TABLE `icdocuments` CHANGE `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL;
  ALTER TABLE `icdocuments` CHANGE `abs_etape_id` `absetape_id` INT(11) DEFAULT NULL;

  ALTER TABLE icmodules CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL;
  ~~~

* Ajouter les colonnes `vu` dans les tables :

* Modification complète de la table `watchers` (peut-êtr qu'il vaut mieux simplement la refaire complètement, mais en fait, il faudra de toutes façons changer les watchers "à la main")
  ~~~SQL
  -- Pour obtenir le schéma
  mysqldump -d -u root icare watchers > watchers.sql
  -- Pour le copier
  mysql icare < watchers.sql
  ~~~
  ~~~SQL
  ALTER TABLE watchers ADD COLUMN `wtype`     VARCHAR(50) NOT NULL AFTER id;
  ALTER TABLE watchers DROP COLUMN `objet_class`;
  ALTER TABLE watchers DROP COLUMN processus;
  ALTER TABLE watchers ADD COLUMN `vu_admin`  BOOL DEFAULT false AFTER data;
  ALTER TABLE watchers ADD COLUMN `vu_user`   BOOL DEFAULT false AFTER `vu_admin`;
  ~~~

* Modifier les icariens suivants:

  ~~~SQL
  ~~~
