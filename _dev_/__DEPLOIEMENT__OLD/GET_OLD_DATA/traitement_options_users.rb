# encoding: UTF-8
=begin
  Script pour conformiser les options des users
=end
puts "Traitement des options des users".bleu

# table users             OK
# -----------
#     synopsis
#       - récuperer data online en transformant :
#         * supprimer colonne adresse, telephone
#       - modifier les options pour intégrer les bits 26:3, 27:3, 28:0
#       - mettre un '-' aux bits 17, 19 et 23
#       - dumper pour exportation
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/users.sql"`
values = []
db_exec(<<-SQL.strip.freeze)
START TRANSACTION;
ALTER TABLE `users` DROP COLUMN `adresse`;
ALTER TABLE `users` DROP COLUMN `telephone`;
ALTER TABLE `users` MODIFY COLUMN `naissance` SMALLINT(4) DEFAULT NULL;
#{change_columns_at('users', ['date_sortie'])}
COMMIT;
SQL
if MyDB.error
  puts MyDB.error.inspect.rouge
  exit 1
end
db_exec('SELECT id, options FROM users WHERE id > 2'.freeze).each do |duser|
  # puts duser.inspect
  opts = duser[:options].ljust(32,'0')
  opts[17] = '-'
  opts[19] = '-'
  opts[23] = '-'
  opts[26] = '3'
  opts[27] = '3'
  opts[28] = '0'
  values << [opts, duser[:id]]
end
unless values.empty?
  db_exec('UPDATE users SET options = ? WHERE id = ?'.freeze, values)
end
# NOTE  L'icarien anonyme (en #9) sera traité plus bas, lorsque toutes
#       les tables auront été traitées. De même que tous les utilisateurs
#       qui se trouvent entre 3 et 10 (pour laisser la place)
