# encoding: UTF-8
=begin
  Ce script permet de détruire complètement un utilisateur dans la base
  distante par son identifiant. Tous les éléments le concernant seront
  détruits de la même manière, c'est une destruction en profondeur.

  Pour certaines choses, comme les lectures QDD ou les questions minifaq,
  elles sont "anonymisées" (user #9).
  La rangée est conservée dans la table users, mais marquée détruite (cf.
  ci-dessous le détail des nouvelles options).
=end

# IDentifiant de l'icarien à détruire
USER_ID = 71


# ---------------------------------------------------------------------
#
#   NE RIEN TOUCHER CI-DESSOUS
#
# ---------------------------------------------------------------------


# Pour faire la modification online
ONLINE = true

# Les options que possèdent un icarien détruit
OPTIONS_ERASED = "-" * 32
OPTIONS_ERASED[0] = "0" # pas un administrateur
OPTIONS_ERASED[1] = "0" # aucun grade
OPTIONS_ERASED[2] = "1" # mail confirmé
OPTIONS_ERASED[3] = "1" # bit destruction
OPTIONS_ERASED[4] = "9" # aucun mail
OPTIONS_ERASED[5] = "2" # ne fait pas le concours
OPTIONS_ERASED[16] = "5" # détruit
OPTIONS_ERASED[20] = "0" # préférence d'entête
OPTIONS_ERASED[21] = "0" # pas d'historique partagé
OPTIONS_ERASED[22] = "0" # pas de notification de message
OPTIONS_ERASED[24] = "0" # pas un "vrai" icarien
OPTIONS_ERASED[26..28] = "000" # aucun contact avec personne


# Les requêtes
REQUEST = <<-SQL
START TRANSACTION;
DELETE FROM watchers WHERE user_id = #{USER_ID};
DELETE FROM tickets WHERE user_id = #{USER_ID};
DELETE FROM actualites WHERE user_id = #{USER_ID};
DELETE FROM connexions WHERE id = #{USER_ID};
DELETE FROM icmodules WHERE user_id = #{USER_ID};
DELETE FROM icetapes WHERE user_id = #{USER_ID};
DELETE FROM icdocuments WHERE user_id = #{USER_ID};
DELETE FROM paiements WHERE user_id = #{USER_ID};
DELETE FROM temoignages WHERE user_id = #{USER_ID};
UPDATE lectures_qdd SET user_id = 9 WHERE user_id = #{USER_ID};
UPDATE minifaq SET user_id = 9 WHERE user_id = #{USER_ID};
UPDATE users SET options = '#{OPTIONS_ERASED}' WHERE id = #{USER_ID};
COMMIT;
SQL


require_relative 'required'

puts "ONLINE = #{ONLINE.inspect}"

if ONLINE
  MyDB.DBNAME = 'icare_db'
else
  MyDB.DBNAME = 'icare_test'
end

res = db_exec(REQUEST)
puts "Résultat de l'opération : #{res.inspect}"
puts "Si toutes les listes sont vides, c'est que l'opération s'est bien passée."
