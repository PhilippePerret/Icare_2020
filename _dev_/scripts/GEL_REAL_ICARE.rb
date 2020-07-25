# encoding: UTF-8
=begin

  Gel Icare permet d'utiliser les données réelles en local.
  Ce script doit être lancé après avoir joué GET_DATA_DB_OLD_SITE.rb qui
  récupère toutes les données de l'ancien atelier (actuel) pour les formater
  au nouveau format.
  À la fin de ce script, les données sont intégralement chargées dans
  `icare_test`

  Ici, tous les cpassword de la table icare_test.users sont modifiées (sauf
  le mien) pour n'utiliser que 'motdepasse' comme mot de passe avec le salt
  qui est conservé, afin de pouvoir utiliser le site avec n'importe quel
  icarien.
=end
# On se place dans l'atelier (on y est puisqu'on lance le script d'ici)

require './_lib/required'
require './_dev_/CLI/lib/required/String' # notamment pour les couleur
require 'digest/md5'

unless defined? ALWAYSDATA_FOLDER
  ALWAYSDATA_FOLDER = '/Users/philippeperret/Sites/AlwaysData'.freeze
end
unless defined? ICARE_FOLDER
  ICARE_FOLDER = File.join(ALWAYSDATA_FOLDER, 'Icare_2020').freeze
end


MyDB.DBNAME = 'icare_test'

# Maintenant, on doit modifier tous les users
# pour pouvoir les utiliser (mot de passe unique mis à 'motdepasse')
REQUEST_UPDATE_PASSWORD = 'UPDATE `users` SET cpassword = ? WHERE id = ?'.freeze
values = []
db_exec("SELECT id, pseudo, mail, salt FROM users WHERE id > 8").each do |duser|
  # print "Traitement de #{duser[:pseudo]}… "
  new_cpassword = Digest::MD5.hexdigest("motdepasse#{duser[:mail]}#{duser[:salt]}")
  values << [new_cpassword, duser[:id]]
  # puts "OK !"
end
db_exec(REQUEST_UPDATE_PASSWORD, values)
puts "Mot de passe des users uniformisés (mis à 'motdepasse').".vert

# Il faut vider certaines tables
db_exec(<<-SQL.strip.freeze)
TRUNCATE `frigo_messages`
TRUNCATE `frigo_discussions`
TRUNCATE `frigo_users`
TRUNCATE `tickets`
SQL
puts "Tables initialisées".vert

`mysqldump -u root icare_test > ./spec/support/Gel/gels/real-icare/icare_test.sql`
puts "Dump effectué dans 'real-icare' (jouer `icare degel real-icare` quand on voudra le retrouver)".vert
