# encoding: UTF-8
# frozen_string_literal: true

request = <<-SQL
START TRANSACTION;
ALTER TABLE `validations_pages`
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
SQL
db_exec(request)
success("#{TABU}Modification des colonnes.")
TableGetter.export('validations_pages')
