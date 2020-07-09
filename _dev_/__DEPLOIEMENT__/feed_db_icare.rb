# encoding: UTF-8
=begin
  Script qui :
  - prend les fichiers sql locaux dans Goods_for_202 et les
    copie dans `deploiement/db` en distant
  - lance les commandes d'alimentation de la base `icare` online
=end

require_relative './required'
#
# # On doit construire le fichier 'www/deploiement/db' sur le site distant
# `ssh #{SERVEUR_SSH} bash <<BASH
# rm -rf "deploiement/db"
# mkdir -p "deploiement/db"
# BASH
# `
# puts "Construction/vidage du dossier ./deploiement/db distant".vert
#
# puts "* Copie des fichiers .sql…".jaune
# Dir["#{FOLDER_GOODS_SQL}/*.sql"].each do |src|
#   src_name = File.basename(src)
#   dst_path = "./deploiement/db/#{src_name}".freeze
#   `scp "#{src}" #{SERVEUR_SSH}:#{dst_path}`
#   puts "\tCOPY: #{dst_path.inspect}"
# end
# puts "Copie des fichiers .sql effectuée".vert

puts "On ne peut pas injecter les tables de façon automatisée. Il faut le faire à la main.".rouge
# require './_lib/data/secret/mysql'
# puts "* Injection des données dans la DB icare…".jaune
# Dir["#{FOLDER_GOODS_SQL}/*.sql"].each do |src|
#   src_name = File.basename(src)
#   cmd = "ssh #{SERVEUR_SSH} bash \"mysql -u icare -p#{DATA_MYSQL[:distant][:password]} icare_db < ./deploiement/db/#{src_name}\" 2>&1"
#   puts "CMD: #{cmd}"
#   res = `#{cmd}`
#   puts "RES: #{res.inspect}"
#   break
# end
# puts "= Données injectées avec succès".vert
