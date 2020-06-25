# Modifications à faire dans la base de données

* Dans `users`

  ~~~SQL
  ALTER TABLE `users` DROP COLUMN `adresse`;
  ALTER TABLE `users` DROP COLUMN `telephone`;
  ALTER TABLE `users` MODIFY COLUMN `naissance` SMALLINT(4) DEFAULT NULL;
  ~~~

* Dans `temoignages`
  ~~~SQL
  ALTER TABLE `temoignages` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL;
  ALTER TABLE `temoignages` DROP COLUMN `user_pseudo`;
  SQL

* Dans `frigos_messages`, `frigo_discussions` (et `frigos` détruite)
  ~~~SQL
  ALTER TABLE frigo_messages ADD COLUMN user_id INT(11) NOT NULL AFTER auteur_ref;
  ALTER TABLE frigo_messages DROP COLUMN auteur_ref;

  ALTER TABLE `frigo_discussions` DROP COLUMN `user_mail`;
  ALTER TABLE `frigo_discussions` DROP COLUMN `user_pseudo`;
  ALTER TABLE `frigo_discussions` DROP COLUMN `cpassword`;
  ALTER TABLE `frigo_discussions` DROP COLUMN `options`;

  DROP TABLE frigos;
  SQL

* Il faut absolument prendre les données de `icare.absmodules` qui ont été affinées

* Table `actualites`. Il ne faut prendre les données qu'à partir du 20 juin 2020 compris, et les transformer :
  * ajouter un `type` 'NOTDEF'
  * ajouter l'user_id à 9
  * supprimer les colonnes `status` et `data`.

  Les données locales peuvent être transmises online.

* Renommer la table `abs_travaux_type` en `abstravauxtypes`

  ~~~SQL
  ALTER TABLE `abs_travaux_type` RENAME `abstravauxtypes`;
  ~~~

* Modifier la table des `paiements`

  ~~~SQL
  ALTER TABLE `paiements` CHANGE COLUMN `facture` `facture_id` VARCHAR(30) NOT NULL;
  ~~~

* Faire l'user 3 qui sera l'user "anonyme", lorsqu'un user détruit son profil.
  MAIS AVANT il faut mettre #3 et #4 autre part et modifier dans toutes les tables (user_id = 3 et user_id = 4)

* Table `absetapes`, remplacer la colonne `module_id` par `absmodule_id`

  ~~~SQL
  ALTER TABLE `absetapes` CHANGE COLUMN `module_id` `absmodule_id` INT(2) NOT NULL
  ALTER TABLE `absetapes` DROP COLUMN `travaux`;
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

* Table `updates`

  ~~~SQL
  DROP TABLE `updates`;
  ~~~


* Modificaitons de la table `icetapes`

  ~~~SQL
  -- Ajouter une colonne created_at
  ALTER TABLE `icetapes` ADD COLUMN `created_at` INT(10) NOT NULL;
  -- Supprimer colonne 'documents'
  ALTER TABLE icetapes DROP COLUMN `documents`;
  ALTER TABLE icetapes DROP COLUMN `numero`;
  ~~~

* Table `mini_faq`
  * Note : si aucune nouvelle question n'est posée, on pourra se servir de
    la table de la base `icare`.
  * Renommée `minifaq`.
  * Destruction de la colonne `content` (qui était une sorte de mise en forme de la question/réponse, donc un gros doublon des données).
  * Destruction de la colonne `user_pseudo`.Et utiliser INNER JOIN users u ON u.id = mf.user_id, u.pseudo AS user_pseudo
  * Destruction de la colonne `numero` (numéro de l'étape, dont on se fiche)
  * Destruction de la colonne `options`
  * Les colonnes `user_id`, `absmodule_id` et `absetape_id` peuvent être nulles.

  ~~~SQL
  ALTER TABLE `mini_faq` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL;
  ALTER TABLE `mini_faq` CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) NOT NULL;
  ~~~

* Table `page_comments`

  ~~~SQL
  DROP TABLE `page_comments`;
  ~~~

* Table `icmodules`

  ~~~SQL
  ALTER TABLE `icmodules` DROP COLUMN `paiements`;
  ALTER TABLE `icmodules` CHANGE COLUMN `next_paiement` `next_paiement_at` INT(10) DEFAULT NULL;
  ALTER TABLE `icmodules` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL;
  ALTER TABLE `icmodules` DROP COLUMN `icetapes`;
  ~~~

* Table `lectures_qdd`

  ~~~SQL
  ALTER TABLE `lectures_qdd` ADD COLUMN `cote_comments` TINYINT(1) DEFAULT NULL AFTER `cotes`;
  ALTER TABLE `lectures_qdd` ADD COLUMN `cote_original` TINYINT(1) DEFAULT NULL AFTER `cotes`;
  ALTER TABLE `lectures_qdd` DROP COLUMN `cotes`;
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
