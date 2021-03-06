# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script permettant d'effectuer un changement dans les données DB de tous les
  gels.
=end

# Le traitement qu'il faut appliquer À TOUS LES GELS des tests
DB_REQUEST = <<-SQL.strip
UPDATE users SET options = "00100000000000004-0-000-11330000" WHERE id IN (13,16,48,93,95,97,104)
SQL
DB_VALUES = nil

def log(msg);puts(msg)end


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
