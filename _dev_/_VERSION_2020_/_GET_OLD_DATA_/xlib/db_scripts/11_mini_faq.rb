# encoding: UTF-8
# frozen_string_literal: true


TableGetter.traite('mini_faq') do
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `minifaq`
  CHANGE COLUMN `abs_module_id` `absmodule_id` INT(2) DEFAULT NULL,
  CHANGE COLUMN `abs_etape_id` `absetape_id` INT(2) DEFAULT NULL,
  DROP COLUMN   `user_pseudo`,
  DROP COLUMN   `content`,
  DROP COLUMN   `numero`,
  DROP COLUMN   `options`,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
UPDATE `minifaq` SET `absmodule_id` = NULL;
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Conformisation de la table 'minifaq'")
end #/ fin du traitement de la table minifaq
