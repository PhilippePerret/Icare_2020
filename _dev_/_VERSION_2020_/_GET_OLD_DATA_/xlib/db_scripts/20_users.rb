# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement de la table des actualités

  Ce module contient les parties :

  * Traitement de l'user inconnu qui doit être mis en ID #9

=end


# *** Traitement de tous les users ***

TableGetter.traite('users') do
  # On traite toutes les options
  values = []
  db_exec('SELECT id, options FROM `users` WHERE id > 2').each do |duser|
    opts = duser[:options].ljust(32,'0')
    opts[17] = '-'
    opts[19] = '-'
    opts[23] = '-'
    opts[26] = '3'
    opts[27] = '3'
    opts[28] = '0'
    values << [opts, duser[:id]]
  end
  db_exec('UPDATE users SET options = ? WHERE id = ?', values)
  success("#{TABU}Conformation de toutes les options.")

  # Modifications mineures
  request = <<-SQL
START TRANSACTION;
ALTER TABLE `users`
  DROP COLUMN `adresse`,
  DROP COLUMN `telephone`,
  MODIFY COLUMN `naissance` SMALLINT(4) DEFAULT NULL,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `date_sortie` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Colonnes de temps modifiés.")
end


# *** USER ANONYME ***

REQUEST_UPDATE_USER9    = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = 9'
REQUEST_UPDATE_USER_ID  = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = %{old_id};'
REQUEST_DELETE_USER     = 'DELETE FROM users WHERE id = %{id}'

duser9 = db_get('users', 9)
unless duser9.nil? # déjà traité
  duser9.delete(:id)
  # On ajoute les données de l'user anonyme
  # On peut créer l'utilisateur 9
  opts = '001090000000000011090009'.ljust(32,'0')
  opts[26] = '0'
  opts[27] = '0'
  opts[28] = '0'
  data_anonymous = {
    id: 9,
    pseudo: 'Anonyme',
    patronyme: 'Anonyme',
    mail:'anonyme@gmail.com',
    naissance: 2000,
    cpassword: 'lepassportsnormalementencrypted',
    salt:'unsel',
    sexe: 'H',
    options: opts
  }
  db_compose_update('users', 9, data_anonymous)
  # On remet l'user 9
  new_user_id = db_compose_insert('users', duser9)
  puts "#{TABU}ID Anonymous: #{new_user_id}" if VERBOSE

  # Il faut remplacer user_id ou owner_id partout où ça peut être utilisé
  # dans toutes les tables.
  lines_update = TABLES_WITH_USER_ID.collect do |table, prop_name|
    prop_name ||= 'user_id'
    REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id, old_id:9}
  end.join(RC)

  request = <<-SQL
START TRANSACTION;
#{lines_update}
COMMIT;
  SQL
  db_exec(request)
  success("#{TABU}Icarien anonyme modifié dans toutes les tables.")
end
success("#{TABU}👍#{ISPACE}Icarien anonyme traité avec succès.")


# *** Traitement des users de 3 à 8 ***

lines_updates = []
db_get_all('users', 'id > 2 AND id < 9').each do |duser|
  user_old_id = duser.delete(:id)
  # Supprimer l'user
  # Note : il faut absolument le faire maintenant, sinon il y aura une erreur
  # de duplication de clé.
  db_exec(REQUEST_DELETE_USER % {id: user_old_id})
  # On insert le nouvel user placé
  new_user_id = db_compose_insert('users', duser)
  puts "#{TABU}Nouvel ID pour user ##{user_old_id} : #{new_user_id}" if VERBOSE
  # Il faut remplacer user_id ou owner_id partout où ça peut être utilisé
  # dans toutes les tables.
  TABLES_WITH_USER_ID.each do |table, prop_name|
    prop_name ||= 'user_id'
    lines_updates << REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id, old_id:user_old_id}
  end
end #/boucle sur chaque user

request = <<-SQL
START TRANSACTION;
#{lines_updates.join(RC)}
UPDATE users SET options = '00119000000000005-0-011-00330000' WHERE ID = 27;
UPDATE users SET options = '01910000000000410-0-081-10330000' WHERE ID = 33;
UPDATE users SET options = '00110000000000004-1-000-11330000' WHERE ID = 34;
UPDATE users SET options = '01910000000000410-0-081-10330000' WHERE ID = 66;
UPDATE users SET options = '01910000000000410-0-081-10330000' WHERE ID = 71;
UPDATE users SET options = '00119000000000002-0-000-15330000' WHERE ID = 100;
COMMIT;
SQL
puts "#{RC}request complète:#{RC}#{request}#{RC}" if VERBOSE
db_exec(request)

success("#{TABU}Icariens ID #3 à #8 déplacés avec succès.")


# *** Opérations spéciales ***
# Destruction de "Naja"
naja = db_get('users', {pseudo: 'Naja'})
unless naja.nil?
  naja[:options][3] = "1"
  db_compose_update('users', naja[:id], {options: naja[:options]})
end

TableGetter.export('users')
