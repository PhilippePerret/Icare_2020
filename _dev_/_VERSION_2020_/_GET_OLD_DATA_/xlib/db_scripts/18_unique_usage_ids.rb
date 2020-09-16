# encoding: UTF-8
# frozen_string_literal: true

# Il faut vider la table avant de l'exporter

request = <<-SQL
START TRANSACTION;
TRUNCATE TABLE `unique_usage_ids`;
ALTER TABLE `unique_usage_ids`
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
SQL
TableGetter.export('unique_usage_ids')
