# encoding: UTF-8
# frozen_string_literal: true


TableGetter.traite('connexions') do
  sql_request = <<-SQL
START TRANSACTION;
ALTER TABLE `connexions`
  MODIFY COLUMN `time` VARCHAR(10) NOT NULL;
COMMIT;
TRUNCATE TABLE `connexions`
  SQL
  db_exec(sql_request)
  success("#{TABU}Column 'time' mis au bon format de temps.")
  success("#{TABU}Table vidée de toutes ses données.")
end
