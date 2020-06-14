# Modifications à faire dans la base de données

* Modifier la table des `paiements`

  ~~~SQL
  ALTER TABLE `paiements` CHANGE COLUMN `facture` `facture_id` VARCHAR(30) NOT NULL;
  ~~~

* Faire l'user 3 qui sera l'user "anonyme", lorsqu'un user détruit son profil.
  MAIS AVANT il faut mettre #3 et #4 autre part et modifier dans toutes les tables (user_id = 3 et user_id = 4)

* Table `absetapes`, remplacer la colonne `module_id` par `absmodule_id`

  ~~~SQL
  ALTER TABLE `absetapes` CHANGE COLUMN `module_id` `absmodule_id` INT(2) NOT NULL
  ~~~

* Dans la table `watchers`, la colonne `data` doit être renommé `params`

* Dans la table `actualites`, supprimer `data` et `status` et faire une colonne `type`.
  Voir les types pour les affecter aux données courantes

* Dans la table `icdocuments`, supprimer ces colonnes :

  ~~~SQL
  ALTER TABLE `icdocuments` DROP COLUMN `absmodule_id`;
  ALTER TABLE `icdocuments` DROP COLUMN `absetape_id`;
  ALTER TABLE `icdocuments` DROP COLUMN `icmodule_id`;
  ALTER TABLE `icdocuments` DROP COLUMN `expected_comments`;
  ALTER TABLE `icdocuments` DROP COLUMN `doc_affixe`;
  ~~~
* Récupérer toutes les données SQL actuelles de l'atelier online

* Modifier ces données, en transformant par exemple `abs_module_id` et `abs_etape_id` en `absmodule_id` et `absetape_id`

* Modifier la table des tickets

  ~~~SQL
  ALTER TABLE tickets MODIFY COLUMN `id` INTEGER(11) AUTO_INCREMENT;
  ~~~

* Voir les colonnes qui ont été supprimées

* Modificaitons de la table `icetapes`

  ~~~SQL
  -- Ajouter une colonne created_at
  ALTER TABLE `icetapes` ADD COLUMN `created_at` INT(10) NOT NULL;
  -- Supprimer colonne 'documents'
  ALTER TABLE icetapes DROP COLUMN `documents`;
  ~~~

* Changer les colonnes `abs_module_id` et `abs_etape_id` de la table `icdocuments` et de la table `icmodules`, `mini_faq`

  ~~~SQL
  ALTER TABLE `icmodules` DROP COLUMN `paiements`;
  ALTER TABLE `icmodules` CHANGE COLUMN `next_paiement` `next_paiement_at` INT(10) DEFAULT NULL;
  ALTER TABLE `icmodules` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL;
  ALTER TABLE `mini_faq` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL;
  ALTER TABLE `mini_faq` CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) NOT NULL;
  ~~~

* Ajouter les colonnes `vu_admin` et `vu_user` dans les tables :

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

## Table `icdocuments`

C'est la table qui va le plus bouger, notamment avec la suppression de l'enregistrement des lectures dedans. On utilise maintenant la table `qdd_lectures`

Il faut donc récupérer les informations des colonnes `cote_original`, `cotes_original`, `cote_comments`, `cotes_comments`, `readers_original` et `readers_comments` pour alimenter cette nouvelle table (en sachant qu'on sera obligé, ici, d'attribuer une note moyenne pour chaque lecture — ou plus exactement une note dont le total devra être cohérent — peut-être, pour simplifier, prendra-t-on une fois la valeur arrondie au-dessus et une fois en dessous).
