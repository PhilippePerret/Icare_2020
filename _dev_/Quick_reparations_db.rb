#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  Pour effectuer des réparations rapides sur la base de données distantes.

  TODO
  - titre par chiffre quand trop long
  - option -f/--formated pour mettre les dates au format humain
=end
ONLINE = true
require_relative './scripts/required'
MyDB.DBNAME = 'icare_db'
MyDB.online = true

=begin
  Exemple de requêtes :
    SELECT * FROM watchers
    ALTER TABLE `frigo_users` ADD COLUMN `last_warned_at` VARCHAR(10) DEFAULT NULL AFTER `user_id`;
=end
# -- Ici la requête --
request = <<-SQL
SELECT * FROM frigo_users;
SQL
result = db_exec(request)
puts "result: #{result.inspect}"

# Si la requête ne renvoie aucun résultat, on peut s'arrêter là
if result.empty?
  puts "Aucun résultat renvoyé par la requête #{request.inspect}"
  exit
end


# La table qui va contenir en clé le nom des colonnes est en
# valeur leur longueur (longueur de la donnée la plus longue)
keys_len = {}
# On initie cette table en mettant au moins une largeur de 3
result.first.keys.each { |c| keys_len.merge!( c => 3 ) }
# On cherche les données les plus longues de chaque colonne
# Une valeur de 8 est donnée par défaut aux colonnes de temps.
result.each do |dat|
  dat.each do |c, v|
    vlen = c.to_s.end_with?("_at") ? 8 : v.to_s.length
    if vlen > keys_len[c]
      keys_len[c] = vlen
    end
  end
end

# *** La ligne d'entête ***
#
# En fait, on fait une ou deux lignes de titre pour avoir
# tous les noms en entier au maximum, par exemple :
# ---------------------------------------------------
#  id status     code   ended_at  etc.
#         titre    started_at     etc.
# ---------------------------------------------------

header1   = []
header2   = []
keys_len_values = keys_len.values
thenext = header1
theprev = header2
headers = {
  up: [], down: [], cur: :up, alt: :down
}
keys_len.each_with_index do |clen, idx|
  c, len = clen
  # Le seul cas particulier, c'est si la longueur du titre
  # courant est plus long que la colonne courante + la colonne
  # suivante + les 2 signes entre les deux colonnes. Dans ce
  # cas exceptionnel, il faut raccourcir le titre
  cs = c.to_s
  tlen = cs.length

  lenmax = len + 2 + (keys_len_values[idx+1]||0)
  if cs.length > lenmax
    cs = cs[0...lenmax]
  else
    cs = cs.ljust(len)
  end
  sp = " ".ljust(len)


  headers[headers[:cur]] << cs
  headers[headers[:alt]] << sp

  # Si la longueur du titre est supérieure à la longueur
  # de la colonne, il faut changer de ligne
  if tlen > len
    headers[:cur], headers[:alt] = [headers[:alt], headers[:cur]]
  end
end

headers[:up] = " #{headers[:up].join('  ')} "
headers[:down] = " #{headers[:down].join('  ')} "
headers.merge!(length: headers[:up].length)


sepline = "-" * headers[:length]


puts "#{"\n"*2}#{sepline}"
puts headers[:up]
puts headers[:down]
puts sepline
# puts "keys_len: #{keys_len.inspect}"
# Ici, on a la plus grande longueur par valeur/colonne
result.each do |dat|
  # puts "dat: #{dat.inspect}"
  line = dat.collect do |c,v|
    v.to_s.ljust(keys_len[c])
  end.join('  ')
  # puts "line: #{line.inspect}"
  puts " #{line} "
end
puts "#{sepline}#{"\n"*2}"
