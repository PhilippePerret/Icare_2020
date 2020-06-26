# encoding: UTF-8
=begin
  Ce script doit permettre de récupérer les étapes de modules les plus
  à jour pour former une table valide à placer sur le site.

  Les trois tables de références sont :

    icare.absetapes
    icare_test.absetapes
    icare.current_absetapes       # version online de absetapes

  AVANT DE LANCER CE SCRIPT :
    - récupérer les données ONLINE de la table icare_modules.absetapes en
      donnant à la table le nom current_absetapes (avec drop if exists)
    - injecter ces données dans icare local
    - lancer le script
=end
require_relative 'required'
MyDB.DBNAME = 'icare'
REQUEST = "SELECT id, updated_at, titre FROM `%s` ORDER BY `id`".freeze
cur_absetapes = db_exec(REQUEST % 'current_absetapes')
ica_absetapes = {}
db_exec(REQUEST % 'absetapes').each do |detape|
  ica_absetapes.merge!(detape[:id] => detape)
end
MyDB.DBNAME = 'icare_test'.freeze
tes_absetapes = {}
db_exec(REQUEST % 'absetapes').each do |detape|
  tes_absetapes.merge!(detape[:id] => detape)
end

WIDTH_TITRE = 40
WIDTH_DATES = 15
UNDEF = ('-undef-'.ljust(WIDTH_DATES)).freeze

def date_for(time)
  ti = Time.at(time)
  da = ti.strftime('%d %m %Y').ljust(WIDTH_DATES)
  return [da, ti.to_i]
end #/ date_for

# Pour mettre toutes les étapes qui devront être actualisées
goods_insert = []
goods_update = []

entete = ("Titre".ljust(WIDTH_TITRE) + "   Current".ljust(WIDTH_DATES) + " icare".ljust(WIDTH_DATES) + " icare_test".ljust(WIDTH_DATES)).freeze
delim = ("-" * entete.length).freeze
puts entete
puts delim
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
  puts "#{titre.ljust(WIDTH_TITRE)}   #{curre_date} #{icare_date} #{tests_date}  #{res}"
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
puts delim

puts "\n\nNouvelles étapes à actualiser :"
MyDB.DBNAME = 'icare'
data_tmp = 'SELECT * FROM absetapes LIMIT 1'.freeze
edata = db_exec(data_tmp).first

if goods_insert.count + goods_update.count == 0
  puts "\n\nToutes les données icare sont à jour !\n\n"
else
  if goods_insert.count > 0
    columns = edata.keys.join(VG)
    interro = Array.new(edata.keys.count,'?').join(VG)
    INSERT_REQUEST = "INSERT INTO `absetapes` (#{columns}) VALUES (#{interro})".freeze
    puts "INSERT_REQUEST: #{INSERT_REQUEST}"
    db_exec(INSERT_REQUEST, goods_insert)
    puts "Nombre d'insertions : #{goods_insert.count}"
  end
  if goods_update.count > 0
    colinter = edata.keys
    colinter.shift # pour enlever l'identifiant
    colinter = colinter.collect{|c| "#{c} = ?"}.join(VG)
    UPDATE_REQUEST = "UPDATE `absetapes` SET #{colinter} WHERE id = ?"
    puts "UPDATE_REQUEST: #{UPDATE_REQUEST}"
    db_exec(UPDATE_REQUEST, goods_update)
    puts "Nombre d'actualisations : #{goods_update.count}"
  end
  # puts goods_update.inspect
end
