#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  Pour afficher de façon intelligente (*) les données de la base distante.

  (*) Les dates sont humanisées, les ID de users remplacés par leur pseudo,
      etc.

  Jouer plutôt le scrit dans le Terminal pour un affichage parfait.
  
=end

# La requête à exécuter pour récupérer les données distantes.
REQUEST = <<-SQL
SELECT id, pseudo, mail FROM users WHERE mail = 'benoitlemeunier@hotmail.fr'
SQL


# Les options
options = {
  time:     {value:true, name:"Changer les timestamp en date", dim: 't'},
  nodate:   {value:false, name:"Passer les created_at et updated_at", dim: 'n'},
  pseudo:   {value:true, name:"Ajouter le pseudo si user_id est défini", dim: 'p'},
}

ONLINE = true
require_relative './lib/required'
MyDB.DBNAME = 'icare_db'
MyDB.online = true

result = db_exec(REQUEST)



# ---------------------------------------------------------------------
#
#   Ne pas toucher ci-dessous sans savoir ce que l'on fait
#
# ---------------------------------------------------------------------


color_method = :bleu

# Si la requête ne renvoie aucun résultat, on peut s'arrêter là
if result.empty?
  puts "Aucun résultat renvoyé par la requête #{request.inspect}"
  exit
end

add_pseudo_user = options[:pseudo][:value] === true

# La table qui va contenir en clé le nom des colonnes et en
# valeur leur longueur (longueur de la donnée la plus longue)
keys_colslen = {}
# On initie cette table en mettant au moins une largeur de 3
result.first.keys.each do |c|
  next if [:created_at, :updated_at].include?(c) && options[:nodate][:value]
  if c == :user_id && add_pseudo_user
    keys_colslen.merge!( user_id: 3, pseudo: 3)
  else
    keys_colslen.merge!( c => 3 )
  end
end

# Si la liste des colonnes (clés) contient :user_id et que l'option :pseudo
# est activée, il faut ajouter le pseudo à l'information user_id
USER_PSEUDOS = {}
if keys_colslen.key?(:user_id) && add_pseudo_user
  users_ids = result.collect{|h|h[:user_id]}
  puts "users_ids: #{users_ids}"
  db_exec("SELECT id, pseudo FROM users WHERE id IN (#{users_ids.join(', ')})").each do |du|
    USER_PSEUDOS.merge!(du[:id] => du[:pseudo])
  end
  # On ajoute les pseudos aux résultats
  result.each do |dat|
    dat.merge!(pseudo: USER_PSEUDOS[dat[:user_id]])
  end
  # puts "result: #{result}"
end

# On cherche les données les plus longues de chaque colonne
# Une valeur de 8 est donnée par défaut aux colonnes de temps.
result.each do |dat|
  keys_colslen.each do |c, maxlen|
    v = dat[c]
    vlen = (c.to_s.end_with?("_at") && options[:time][:value]) ? 8 : v.to_s.length
    if vlen > keys_colslen[c]
      keys_colslen[c] = vlen
    end
  end
end

# La table contenant en clé le nom de la colonne et en valeur
# l'indentation horizontale
cols_ind = []
hindent = 0
keys_colslen.each do |col, len|
  cols_ind << hindent
  hindent += len + 2
end
cols_ind << hindent # le dernier

# *** La ligne d'entête ***
#
# Dans cette partie, on fabrique la ligne d'entête avec le nom
# des colonnes.
# En fait, on fait une ou deux lignes de titre pour avoir
# tous les noms en entier au maximum, par exemple :
# ---------------------------------------------------
#  id status     code   ended_at  etc.
#         titre    started_at     etc.
# ---------------------------------------------------

keys_colslen_values = keys_colslen.values
header1 = ""
header2 = ""
header3 = "" # peut-être ne servira pas

keys_colslen.each_with_index do |titfixlen, idx|

  tit, fixlen = titfixlen

  tit = "uid" if tit == :user_id && add_pseudo_user

  # La colonne doit commencer à l'index +deb+
  deb = cols_ind[idx]
  fin = cols_ind[idx + 1]

  # puts "\n[deb:#{deb}, fin:#{fin}, h1 len:#{header1.length}, h2 len:#{header2.length}]"

  if header1.length - 1 < deb
    header1 = "#{header1.ljust(deb)}#{tit} ".ljust(fin)
  elsif header2.length - 1 < deb
    # On doit mettre sur la ligne d'entête 2
    header2 = "#{header2.ljust(deb)}#{tit} ".ljust(fin)
  else
    header3 = "#{header3.ljust(deb)}#{tit} ".ljust(fin)
  end

  # puts "header1: #{header1.inspect}"
  # puts "header2: #{header2.inspect}"
  # puts "header3: #{header3.inspect}"

end

# headers[:up] = " #{headers[:up].join('  ')} "
# headers[:down] = " #{headers[:down].join('  ')} "
# headers.merge!(length: headers[:up].length)

headers = []
headers << " #{header1} "
headers << " #{header2} " unless header2.empty?
headers << " #{header3} " unless header3.empty?

header_length = headers.collect{|h|h.length}.max

sepline = "-" * header_length

puts "#{"\n"*2}#{sepline}".send(color_method)
puts headers.join("\n").send(color_method)
puts sepline.send(color_method)

# puts "keys_colslen: #{keys_colslen.inspect}"
# Ici, on a la plus grande longueur par valeur/colonne
DDMMYY = '%d/%m/%y'
result.each do |dat|
  # puts "dat: #{dat.inspect}"
  line = keys_colslen.collect do |c, maxlen|
    v = dat[c]
    if v.nil?
      v = " - "
    elsif c.to_s.end_with?('_at')
      v = v.empty? ? "" : Time.at(v.to_i).strftime(DDMMYY)
    else
      v = v.to_s
    end
    v.ljust(keys_colslen[c])
  end.compact.join('  ')
  # puts "line: #{line.inspect}"
  puts " #{line} ".send(color_method)
end
puts "#{sepline}#{"\n"*2}".send(color_method)
