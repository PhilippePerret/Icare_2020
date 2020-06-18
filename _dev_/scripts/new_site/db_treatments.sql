-- Ce module contient toutes les opérations à faire subir
-- aux anciennes données SQL pour être conformes

USE icare

-- Table des travaux types
ALTER TABLE `abs_travaux_type` RENAME `abstravauxtype`;
ALTER TABLE `abstravauxtypes` CHANGE COLUMN `short_name` `name` VARCHAR(200) NOT NULL;

-- TABLE DES TÉMOIGNAGES
ALTER TABLE `temoignages` CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL;
ALTER TABLE `temoignages` ADD COLUMN `plebiscites` TINYINT DEFAULT 1 AFTER `content`;
