# encoding: UTF-8
=begin
  Gel Icare permet d'utiliser les données réelles en local.
  Ce script doit être lancé après avoir joué _SCRIPT_NEW_ATELIER_.rb qui
  récupère toutes les données de l'ancien atelier (actuel) pour les formater
  au nouveau format.
  Ensuite, ces données sont intégralement chargées dans icare_test
  Et enfin, toutes les données cpassword de la table icare_test.users sont
  modifiées pour n'utiliser que 'motdepasse' comme mot de passe avec le salt
  qui est conservé, afin de pouvoir utiliser le site avec n'importe quel
  icarien.
=end
# On se place dans l'atelier (on y est puisqu'on lance le script d'ici)

require './_lib/required'
require './_dev_/CLI/lib/required/String' # notamment pour les couleur
require 'digest/md5'

# D'abord, on dumpe toutes les données de icare
`mysqldump -u root icare > ./tmp/icare.sql`
puts "Données icare exportées avec succès.".vert

`mysql -u root icare_test < ./tmp/icare.sql`
puts "Données icare importées dans icare_test avec succès".vert

MyDB.DBNAME = 'icare_test'

# Maintenant, on doit modifier tous les users
REQUEST_UPDATE_PASSWORD = 'UPDATE `users` SET cpassword = ? WHERE id = ?'.freeze
values = []
db_exec("SELECT id, pseudo, mail, salt FROM users").each do |duser|
  print "Traitement de #{duser[:pseudo]}… "
  new_cpassword = Digest::MD5.hexdigest("motdepasse#{duser[:mail]}#{duser[:salt]}")
  values << [new_cpassword, duser[:id]]
  puts "OK !"
end
db_exec(REQUEST_UPDATE_PASSWORD, values)
puts "Mot de passe des users uniformisés (mis à 'motdepasse').".vert
