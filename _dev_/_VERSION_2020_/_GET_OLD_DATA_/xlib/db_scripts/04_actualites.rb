# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement de la table des actualités
=end
TableGetter.traite('actualites') do
  request = <<-SQL
  START TRANSACTION;
  ALTER TABLE `actualites`
    MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
    MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL,
    DROP COLUMN `status`;
  COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Colonnes de temps modifiées.")
  success("#{TABU}Suppression de la colonne 'status'.")
end