# encoding: UTF-8
# frozen_string_literal: true

# Il faut vider la table avant de l'exporter

request = <<-SQL
START TRANSACTION;
DROP TABLE IF EXISTS `unique_usage_ids`;
CREATE TABLE `unique_usage_ids` (
  uuid        VARCHAR(20),
  session_id  VARCHAR(32),
  user_id     INT(11),
  scope       VARCHAR(32),
  created_at  VARCHAR(10) DEFAULT NULL,
  updated_at  VARCHAR(10) DEFAULT NULL
);
COMMIT;
SQL
db_exec(request)
success("#{TABU}Modification des colonnes.")
TableGetter.export('unique_usage_ids')
