# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement des icmodules et icetapes
=end

TableGetter.traite('icetapes') do
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `icetapes`
  DROP COLUMN `numero`,
  DROP COLUMN `documents`,
  CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) NOT NULL,
  MODIFY COLUMN `started_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `expected_end` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `expected_comments` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `ended_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL,
  ADD COLUMN `created_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Modification des colonnes")
end

TableGetter.traite('icmodules') do
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `icmodules`
  DROP COLUMN `icetapes`,
  DROP COLUMN `paiements`,
  DROP COLUMN `next_paiement`,
  CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) NOT NULL,
  MODIFY COLUMN `started_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `ended_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
UPDATE `icmodules` SET pauses = NULL WHERE pauses = "[{";
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Modification des colonnes")

end
