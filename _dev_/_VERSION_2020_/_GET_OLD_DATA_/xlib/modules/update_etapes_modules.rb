# encoding: UTF-8
# frozen_string_literal: true
=begin
  Ce script permet de récupérer les étapes de modules les plus
  à jour pour former une table valide à placer sur le site qui sera enregistrée
  dans le dossier `xbackup/Goods_for_2020/`

  Les trois tables de références sont :

    icare.absetapes               # La bonne à la fin
    icare_test.absetapes
    icare.current_absetapes       # version online de absetapes

  AVANT DE LANCER CE SCRIPT :
    - récupérer les données ONLINE de la table icare_modules.absetapes en
      donnant à la table le nom current_absetapes (avec drop if exists) dans
      le dossier cd ~/Sites/AlwaysData/xbackups/Version_current_online/
    - injecter ces données dans `icare` local (pas `icare_test`)
        $> cd ~/Sites/AlwaysData/xbackups/Version_current_online/
        $> mysql -u root icare < current_absetapes.sql
    - lancer ce script


=end
VERBOSE = true unless defined?(VERBOSE)

REQUEST = "SELECT id, updated_at, titre FROM `%s` ORDER BY id"
cur_absetapes = db_exec(REQUEST % 'current_absetapes')
ica_absetapes = {}
db_exec(REQUEST % 'absetapes').each do |detape|
  ica_absetapes.merge!(detape[:id] => detape)
end
MyDB.DBNAME = 'icare_test'
tes_absetapes = {}
db_exec(REQUEST % 'absetapes').each do |detape|
  tes_absetapes.merge!(detape[:id] => detape)
end

WIDTH_TITRE = 40
WIDTH_DATES = 15
UNDEF = ('-undef-'.ljust(WIDTH_DATES))

def date_for(time)
  ti = Time.at(time.to_i)
  da = ti.strftime('%d %m %Y').ljust(WIDTH_DATES)
  return [da, ti.to_i]
end #/ date_for

# Pour mettre toutes les étapes qui devront être actualisées
goods_insert = []
goods_update = []

entete = ("Titre".ljust(WIDTH_TITRE) + "   Current".ljust(WIDTH_DATES) + " icare".ljust(WIDTH_DATES) + " icare_test".ljust(WIDTH_DATES))
delim = ("-" * entete.length)
puts entete   if VERBOSE
puts delim    if VERBOSE
cur_absetapes.each do |detape|
  id = detape[:id]
  curre_date, curre_time = date_for(detape[:updated_at])
  unless ica_absetapes[id].nil?
    icare_date, icare_time = date_for(ica_absetapes[id][:updated_at])
  else
    icare_date = UNDEF
    icare_time = 0 # ATTENTION : si on change la valeur, cf. is_new_etape ci-dessous
  end
  unless tes_absetapes[id].nil?
    tests_date, tests_time = date_for(tes_absetapes[id][:updated_at])
  else
    tests_date = UNDEF
    tests_time = 0
  end
  if icare_time >= curre_time && icare_time >= tests_time
    res = "ICARE"
  elsif curre_time > icare_time && curre_time > tests_time
    res = "current"
  elsif tests_time > curre_time && tests_time > icare_time
    res = "tests"
  else
    res = "IMPOSSIBLE"
  end

  is_new_etape = icare_time == 0

  titre = detape[:titre]
  titre = titre[0...WIDTH_TITRE - 1]+'…' if titre.length > WIDTH_TITRE
  puts "#{titre.ljust(WIDTH_TITRE)}   #{curre_date} #{icare_date} #{tests_date}  #{res}" if VERBOSE
  case res
  when 'ICARE'
    # Rien à faire, elle est bonne au bon endroit
  when 'current'
    ddata = db_get('icare.current_absetapes', id).values
    # ddata.merge!({
    #   absmodule_id: ddata.delete(:module_id)
    # })
    if is_new_etape
      goods_insert << ddata
    else
      ddata << ddata.shift # retirer l'identifiant
      goods_update << ddata
    end
  when 'tests'
    ddata = db_get('icare_test.absetapes', id).values
    if is_new_etape
      goods_insert << ddata
    else
      ddata << ddata.shift # retirer l'identifiant
      goods_update << ddata
    end
  end
end
puts delim if VERBOSE

puts "\n\nNouvelles étapes à actualiser :" if VERBOSE
MyDB.DBNAME = 'icare'
data_tmp = 'SELECT * FROM absetapes LIMIT 1'
edata = db_exec(data_tmp).first

if goods_insert.count + goods_update.count == 0
  puts "#{TABU}Toutes les données absetapes sont à jour !".vert
else
  if goods_insert.count > 0
    columns = edata.keys.join(VG)
    interro = Array.new(edata.keys.count,'?').join(VG)
    INSERT_REQUEST = "INSERT INTO `absetapes` (#{columns}) VALUES (#{interro})"
    puts "INSERT_REQUEST: #{INSERT_REQUEST}" if VERBOSE
    db_exec(INSERT_REQUEST, goods_insert)
    puts "Nombre d'insertions : #{goods_insert.count}" if VERBOSE
  end
  if goods_update.count > 0
    colinter = edata.keys
    colinter.shift # pour enlever l'identifiant
    colinter = colinter.collect{|c| "#{c} = ?"}.join(VG)
    UPDATE_REQUEST = "UPDATE `absetapes` SET #{colinter} WHERE id = ?"
    puts "UPDATE_REQUEST: #{UPDATE_REQUEST}" if VERBOSE
    db_exec(UPDATE_REQUEST, goods_update)
    puts "#{TABU}Nombre d'actualisations des absetapes : #{goods_update.count}".vert
  end
end

# On s'assure que ce soit la même base
MyDB.DBNAME = 'icare'
