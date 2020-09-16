# encoding: UTF-8
=begin
  Traitement des icariens qui se trouvent entre l'id 3 et l'id 8, pour
  les déplacer plus loin.
=end
puts "Traitement des icariens entre 3 et 8…".bleu
# ---------------------------------------------------------------------
#   Déplacement de tous les users de 3 à 8 vers d'autres emplacements
#   pour laisser libre jusqu'à 9 (anonyme)
# ---------------------------------------------------------------------
db_get_all('users', 'id > 2 AND id < 9').each do |duser|
  user_old_id = duser.delete(:id)
  db_exec(REQUEST_DELETE_USER % {id: user_old_id})
  new_user_id = db_compose_insert('users', duser)
  if MyDB.error
    puts MyDB.error.inspect
    exit
  end
  puts "Nouvel ID pour user ##{user_old_id} : #{new_user_id}" if DEBUG > 5
  # Il faut remplacer user_id ou owner_id partout où ça peut être utilisé
  # dans toutes les tables.
  TABLES_WITH_USER_ID.each do |table, prop_name|
    prop_name ||= 'user_id'
    db_exec(REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id, old_id:user_old_id})
    if MyDB.error
      puts MyDB.error.inspect
      exit
    end
  end
end #/boucle sur chaque user
puts "Les icariens entre l'ID #3 et l'ID #8 ont été déplacés.".vert
# On peut exporter la table users
`mysqldump -u root icare users > "#{FOLDER_GOODS_SQL}/users.sql"`
puts "🗄️ Table users exportée.".vert
