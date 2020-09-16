# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement de la table témoignage
=end

# On importe les données distantes dans la base `icare` locale
TableGetter.import('temoignages')

# La requête SQL complète
request = <<-SQL
START TRANSACTION;
ALTER TABLE `temoignages`
  ADD COLUMN `plebiscites` TINYINT DEFAULT 0 AFTER `confirmed`,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL,
  CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL,
  DROP COLUMN `user_pseudo`;
UPDATE temoignages SET confirmed = TRUE;
COMMIT;
SQL
db_exec(request)


TableGetter.export('temoignages')
