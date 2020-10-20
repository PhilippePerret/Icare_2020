# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script permettant d'effectuer un changement dans les données DB de tous les
  gels.
=end

# Le traitement qu'il faut appliquer À TOUS LES GELS des tests
DB_REQUEST = <<-SQL.strip
UPDATE absmodules SET short_description = ? WHERE id = ?;
SQL
DB_VALUES = ["<p>Ce module d’un caractère particulier permet de travailler de façon intensive — ou pas, suivant votre propre rythme — sur un “projet” de type quelconque (roman, concours, film, dossier).</p><p>Depuis sa création, ce module a notamment été utilisé pour :</p><ul>  <li>élaborer un scénario de court-métrage,</li><li>réaliser le dossier de présentation d’une bible,</li><li>établir des dossiers de demande d’aide à l’écriture,</li><li>préparer le concours du CEEA (une des deux fois avec succès),</li><li>préparer le concours d’entrée dans un master de scénario (avec succès),</li><li>développer le synopsis de plusieurs histoires (dans le but de choisir la meilleure),</li><li>être accompagnée dans la rédaction d’un roman jeunesse (sur plusieurs modules),</li><li>établir des dossiers de candidatures à des concours,</li><li>retravailler un roman adulte (faire une ré-écriture accompagnée complète — dont un roman publié à compte d’éditeur).</li></ul>", 12]


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
