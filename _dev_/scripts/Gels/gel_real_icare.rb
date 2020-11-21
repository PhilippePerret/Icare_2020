# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce module permet de produire un gel avec les données actuelles de l'atelier
  ONLINE qui s'appelle 'real-icare'.
  Il met tous les mots de passe à la même valeur pour pour s'identifier en
  local avec simplement "unmotdepasse"
=end
GEL_NAME = "real-icare"
GEL_DESCRIPTION = <<-TEXT
Gel produit d'après les données courantes de l'atelier distant (en ligne).
Tout est mis, depuis les données utilisateurs, les données concours jusqu'aux
watchers et autres tickets.
Ce gel a été produit suivant l'état du site le 20 novembre 2020.
Pour reproduire ce gel :
  * uploader la base 'icare_db' entière du site distant
  * injecter les données dans 'icare_test' (mysql -u root icare_test < path/to/.sql)
  * lancer ce script par CMD-i
TEXT

# ---------------------------------------------------------------------
#
#   NE RIEN TOUCHE EN DESSOUS SANS SAVOIR CE QUE L'ON FAIT
#
# ---------------------------------------------------------------------

ONLINE = false
require_relative '../required_mini'
MyDB.DBNAME = 'icare_test'
MyDB.online = false

require 'digest/md5'
commit = []
db_exec("SELECT mail, salt, id, pseudo FROM users WHERE id > 9").each do |du|
  cpass = Digest::MD5.hexdigest("unmotdepasse#{du[:mail]}#{du[:salt]}")
  commit << "(#{du[:id]}, '#{cpass}')"
end
request = "INSERT IGNORE INTO users (id, cpassword) VALUES #{commit.join(', ')} ON DUPLICATE KEY UPDATE cpassword = VALUES(cpassword)"
puts "Requête : #{request}"
res = db_exec(request)
puts "Retour de requête : #{res.inspect}"

require './spec/support/Gel/lib/Gel.rb'
# On produit le gel
gel(GEL_NAME, GEL_DESCRIPTION)
