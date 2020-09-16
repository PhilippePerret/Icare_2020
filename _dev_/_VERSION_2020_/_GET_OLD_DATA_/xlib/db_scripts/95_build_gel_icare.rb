# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour construire le Gel avec toutes les données icare distantes
  Permet d'obtenir des icariens et icariennes de toute sorte.
=end
operation("📲 Injection dans icare_test et gel real-icare…")

PATH_TOTAL_DUMP_ICARE = "./tmp/icare.sql"

# On dumpe toutes les données de icare
`mysqldump -u root icare > #{PATH_TOTAL_DUMP_ICARE}`
if File.exists?(PATH_TOTAL_DUMP_ICARE)
  success("Données icare exportées avec succès.")
else
  failure("Impossible de trouver le fichier #{PATH_TOTAL_DUMP_ICARE}")
  exit
end

# Chargement dans la table icare_test
# -----------------------------------
# Pour s'assurer que ça s'est bien passé, on détruit la table
# unique_usage_uuid qui doit être reconstruite
db_exec("DROP TABLE IF EXISTS `unique_usage_ids`")
`mysql -u root icare_test < #{PATH_TOTAL_DUMP_ICARE}`
tables = db_exec("SHOW TABLES;").collect { |d| d.values.first }
if tables.include?('unique_usage_ids')
  success("#{TABU}Données icare importées dans icare_test avec succès")
else
  failure("#{TABU}Problème en important les données dans icare_test.")
end

# Pour ne pas l'envoyer par mégarde, on le détruit
File.delete('./tmp/icare.sql')

load './_dev_/scripts/GEL_REAL_ICARE.rb'
puts "Le gel real-icare a été produit avec succès".vert
