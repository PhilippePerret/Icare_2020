# encoding: UTF-8
=begin
  Traitement de l'icarien anonyme
=end
puts "👨‍🎓👩‍🎓Traitement de l'icarien anonyme…".bleu


# DÉPLACEMENT DE L'ICARIEN ANONYME
# --------------------------------
# On doit déplacer le user 9 pour réserver cette place à un anonyme

# Pour tester avant le grand saut :
# if db_count('users', {id:9}) == 0
#   puts "Je mets Marion en #9"
#   db_exec('UPDATE users SET id = 9 WHERE id = 10'.freeze)
# end

TABLES_WITH_USER_ID =   [
  ['watchers'],
  ['icmodules'],
  ['actualites'],
  ['connexions', 'id'],
  ['icdocuments'],
  ['icetapes'],
  ['icmodules'],
  ['lectures_qdd'],
  ['minifaq'],
  ['paiements'],
  ['temoignages'],
  ['tickets'],
  ['watchers']
]

REQUEST_UPDATE_USER9 = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = 9'
REQUEST_UPDATE_USER_ID = 'UPDATE %{table} SET %{prop} = %{id} WHERE %{prop} = %{old_id}'
REQUEST_DELETE_USER = 'DELETE FROM users WHERE id = %{id}'

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
  if MyDB.error
    puts MyDB.error.inspect
    exit
  end
  puts "Nouvel ID pour l'anonyme : #{new_user_id}"

  # Il faut remplacer user_id ou owner_id partout où ça peut être utilisé
  # dans toutes les tables.
  TABLES_WITH_USER_ID.each do |table, prop_name|
    prop_name ||= 'user_id'
    db_exec(REQUEST_UPDATE_USER_ID % {table:table, prop:prop_name, id:new_user_id, old_id:9})
    if MyDB.error
      puts MyDB.error.inspect
      exit
    end
  end
end
puts "Icarien anonyme traité avec succès.".vert
