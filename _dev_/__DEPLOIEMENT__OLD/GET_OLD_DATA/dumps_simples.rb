# encoding: UTF-8
=begin
  Dumps simples
=end
# temoignages         OK    icare > online
# Il faut s'assurer que la colonne `prebiscites TINYINT` existe bien (elle
# disparait si on utilise l'ancienne table online)
`mysqldump -u root icare temoignages > "#{FOLDER_GOODS_SQL}/temoignages.sql"`
puts "🗄️ Dumping des témoignages effectué avec succès".vert

# actualites          OK    online > Faire une sauvegarde pour les garder
#                           On repart à zéro en ajoutant l'actualité du nouveau site
db_exec(change_columns_at('actualites'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
`mysqldump -d -u root icare actualites > "#{FOLDER_GOODS_SQL}/actualites.sql"`
puts "🗄️ Dumping de la table actualites effectué avec succès".vert

# checkform           OK    À détruire

# connexions          OK    Repartir de zéro (structure only)
`mysqldump -d -u root icare connexions > "#{FOLDER_GOODS_SQL}/connexions.sql"`
puts "🗄️ Dumping de la table connexions effectué avec succès".vert

# tickets             OK    Repartir de zéro (structure only)
`mysqldump -d -u root icare tickets > "#{FOLDER_GOODS_SQL}/tickets.sql"`
db_exec(change_columns_at('tickets'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
puts "🗄️ Dumping de la table tickets effectué avec succès".vert

# absmodules          OK    Prendre les données locales dans icare
`mysqldump -u root icare absmodules > "#{FOLDER_GOODS_SQL}/absmodules.sql"`
db_exec(change_columns_at('absmodules'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
puts "🗄️ Dumping des modules absolus effectué avec succès".vert

# absetapes           OK    Après avoir joué update_etapes_modules.rb, prendre
#                           les données dans le fichier absetapes.sql produit
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_absetapes.sql"`
require './_dev_/scripts/new_site/update_etapes_modules'
db_exec(change_columns_at('absetapes'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
`mysqldump -u root icare absetapes > "#{FOLDER_GOODS_SQL}/absetapes.sql"`
puts "🗄️ Dumping des étapes absolues effectué avec succès".vert

# abstravauxtypes     OK    Prendre les données locales dans icare (PAS icare_test)
`mysqldump -u root icare abstravauxtypes > "#{FOLDER_GOODS_SQL}/abstravauxtypes.sql"`
db_exec(change_columns_at('abstravauxtypes'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
puts "🗄️ Dumping des travaux absolus effectué avec succès".vert

# frigos (3 tables)   OK    Rien à récupérer. Prendre la structure des trois
#                           tables frigo_discussions, frigo_users, frigo_messages
db_exec(change_columns_at('frigo_discussions'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
`mysqldump -d -u root icare frigo_discussions > "#{FOLDER_GOODS_SQL}/frigo_discussions.sql"`
db_exec(change_columns_at('frigo_users'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
`mysqldump -d -u root icare frigo_users > "#{FOLDER_GOODS_SQL}/frigo_users.sql"`
db_exec(change_columns_at('frigo_messages'))
if MyDB.error then puts "ERREUR SQL: #{MyDB.error.inspect}".rouge; exit end
`mysqldump -d -u root icare frigo_messages > "#{FOLDER_GOODS_SQL}/frigo_messages.sql"`
puts "🗄️ Dumping du frigo effectué avec succès".vert
