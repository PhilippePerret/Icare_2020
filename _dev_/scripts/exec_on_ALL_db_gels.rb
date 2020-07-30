# encoding: UTF-8
=begin
  Script permettant d'effectuer un changement dans les données DB de tous les
  gels.
=end
PV = ';'.freeze unless defined?(PV)
DB_REQUEST = <<-SQL.strip.freeze
DROP TABLE IF EXISTS `unique_usage_ids`;
CREATE TABLE `unique_usage_ids`
(
  user_id     INT(11) DEFAULT NULL,
  session_id  VARCHAR(32) NOT NULL,
  uuid        SMALLINT NOT NULL,
  scope       VARCHAR(32) DEFAULT NULL,
  created_at  INT(10) NOT NULL,
  updated_at  INT(10) NOT NULL,
  PRIMARY KEY (uuid)
);
SQL


require './_lib/required/__first/db'
MyDB.DBNAME = 'icare_test'

GELS_FOLDER_PATH = File.expand_path('./spec/support/Gel/gels')
Dir["#{GELS_FOLDER_PATH}/*"].each do |gel_folder|
  puts "Traitement du gel '#{gel_folder}'".freeze
  sql_file = File.join(gel_folder, 'icare_test.sql')
  # On le charge dans la base actuelle
  `mysql -u root icare_test < "#{sql_file}"`
  # On effectue les changements
  db_exec(DB_REQUEST)
  # On dumpe les données
  `mysqldump -u root icare_test > "#{sql_file}"`
end

puts "\n\n=== TRAITEMENT TERMINÉ AVEC SUCCÈS ==="
