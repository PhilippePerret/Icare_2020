# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement de la table des actualités
=end
TableGetter.traite('absmodules') do
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `absmodules`
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Colonnes de temps modifiés.")
end
