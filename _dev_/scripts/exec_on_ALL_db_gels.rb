# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script permettant d'effectuer un changement dans les données DB de tous les
  gels.
=end

# Le traitement qu'il faut appliquer
DB_REQUEST = <<-SQL.strip
-- ALTER TABLE `unique_usage_ids` CHANGE COLUMN `uuid` `uuid` VARCHAR(20) NOT NULL UNIQUE;
ALTER TABLE `icmodules` CHANGE COLUMN `started_at` `started_at` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icmodules` CHANGE COLUMN `created_at` `created_at` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icmodules` CHANGE COLUMN `updated_at` `updated_at` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icmodules` CHANGE COLUMN `ended_at` `ended_at` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icetapes` CHANGE COLUMN `started_at` `started_at` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icetapes` CHANGE COLUMN `expected_end` `expected_end` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icetapes` CHANGE COLUMN `expected_comments` `expected_comments` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icetapes` CHANGE COLUMN `ended_at` `ended_at` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icetapes` CHANGE COLUMN `created_at` `created_at` VARCHAR(10) DEFAULT NULL;
ALTER TABLE `icetapes` CHANGE COLUMN `updated_at` `updated_at` VARCHAR(10) DEFAULT NULL;
SQL


PV = ';' unless defined?(PV)
require './_lib/required/__first/db'
MyDB.DBNAME = 'icare_test'

GELS_FOLDER_PATH = File.expand_path('./spec/support/Gel/gels')
Dir["#{GELS_FOLDER_PATH}/*"].each do |gel_folder|
  puts "Traitement du gel '#{gel_folder}'"
  sql_file = File.join(gel_folder, 'icare_test.sql')
  # On le charge dans la base actuelle
  `mysql -u root icare_test < "#{sql_file}"`
  # On effectue les changements
  db_exec(DB_REQUEST)
  # On dumpe les données
  `mysqldump -u root icare_test > "#{sql_file}"`
end

puts "\n\n=== TRAITEMENT TERMINÉ AVEC SUCCÈS ==="
