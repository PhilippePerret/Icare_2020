# encoding: UTF-8
=begin
  Injection des tables conformisées dans la base icare_test pour
  pouvoir produire le gel 'real-icare'
=end
puts "📲 Injection dans icare_test et gel real-icare…".bleu

# D'abord, on dumpe toutes les données de icare
`mysqldump -u root icare > ./tmp/icare.sql`
puts "Données icare exportées avec succès.".vert

`mysql -u root icare_test < ./tmp/icare.sql`
puts "Données icare importées dans icare_test avec succès".vert

# Pour ne pas l'envoyer par mégarde, on le détruit
File.delete('./tmp/icare.sql')

load './_dev_/scripts/GEL_REAL_ICARE.rb'
puts "Le gel real-icare a été produit avec succès".vert
