# encoding: UTF-8
=begin
  Script pour faire l'user anonyme
  Il faut prendre l'user se trouvant à la position #9 et le mettre dans un
  ID libre.
  Il faut modifier partout où il peut se trouver ailleurs.
=end
require_relative '../required'

MyDB.DBNAME = 'icare'
neuf = db_get('users', {id: 9})
neuf.delete(:id)
puts "user: #{neuf.inspect}"

REQUEST_DELETE = "DELETE FROM `users` WHERE id = 9"
db_exec(REQUEST_DELETE)
if MyDB.error
  raise MyDB.error.inspect
end
puts "Destruction de la ligne 9 effectuée."

# On le crée à sa nouvelle position
new_id = db_compose_insert('users', neuf)
if MyDB.error
  raise MyDB.error.inspect
end
new_id > 0 || raise("L'identifiant ne devrait pas être 0")
puts "Nouvel identifiant pour neuf: #{new_id}"

# On cherche dans toutes les tables où il peut se trouver et on remplace
# 9 par son nouvel identifiant.
REQUEST = "UPDATE `%s` SET user_id = #{new_id} WHERE user_id = 9"
[
  'actualites','frigo_discussions', 'icdocuments', 'icetapes', 'icmodules',
  'lectures_qdd', 'minifaq','paiements','temoignages', 'tickets', 'watchers'
].each do |table|
  db_exec(REQUEST % [table])
  if MyDB.error
    raise MyDB.error.inspect
  end
end

REQUEST_OWNER = "UPDATE `frigo_discussions` SET owner_id = #{new_id} WHERE owner_id = 9"
db_exec(REQUEST_OWNER)
if MyDB.error
  raise MyDB.error.inspect
end

# On peut créer l'utilisateur 9
opts = '001090000000000011090009'.ljust(32,'0')
opts[26] = '0'
opts[27] = '0'
opts[28] = '0'
data = {
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
db_compose_insert('users', data)
if MyDB.error
  raise MyDB.error.inspect
end
puts "L'icarien anonyme a été créé avec succès."
