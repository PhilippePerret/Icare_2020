# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script permettant d'effectuer un changement dans les données DB de tous les
  gels.
=end

# Le traitement qu'il faut appliquer À TOUS LES GELS des tests
DB_REQUEST = <<-SQL.strip
DROP TABLE IF EXISTS `concours`;
CREATE TABLE `concours` (
  annee       VARCHAR(4) NOT NULL,
  theme       VARCHAR(100) NOT NULL,
  step        INTEGER(1) NOT NULL DEFAULT 0,
  prix1       VARCHAR(200),
  prix2       VARCHAR(200),
  prix3       VARCHAR(200),
  prix4       VARCHAR(200),
  prix5       VARCHAR(200),
  created_at  VARCHAR(10),
  updated_at  VARCHAR(10)
);
SQL
DB_VALUES = nil


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
  if DB_VALUES
    db_exec(DB_REQUEST, DB_VALUES)
  else
    db_exec(DB_REQUEST)
  end
  # On dumpe les données
  `mysqldump -u root icare_test > "#{sql_file}"`
end

puts "\n\n=== TRAITEMENT TERMINÉ AVEC SUCCÈS ==="
