# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement de la table des actualités
=end
TableGetter.traite('absetapes') do

  VERBOSE = false
  require './_dev_/_VERSION_2020_/_GET_OLD_DATA_/xlib/modules/update_etapes_modules'

  request = <<-SQL
START TRANSACTION;
ALTER TABLE `absetapes`
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Colonnes de temps modifiés.")
end
