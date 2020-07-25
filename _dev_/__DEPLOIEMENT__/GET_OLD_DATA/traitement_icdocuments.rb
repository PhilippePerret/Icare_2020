# encoding: UTF-8
=begin
  Traitement de la table icdocuments
=end
puts "Traitement de la table icdocuments (documents des icariens)".bleu

#
# icdocuments         OK
#       Gros travail de récupération des données :
#       - changement du nom des colonnes
#       - retrait de ce qui relève des commentaires
#       - alimentation de la table `lectures_qdd`
#       Détails :
#         - colonne `abs_module_id` DROP
#         - colonne `abs_etape_id`  DROP
#         - icmodule_id   DROP
#         - icetape_id  En fait, on ne garde que celle-là, à propos des modules/etapes
#         - doc_affixe    DROP
#         - cote_original DROP
#         - cote_comments DROP
#         - expected_comments   DROP
#         - cotes_original      DROP (mais au début, voir quand même si valeur)
#         - cotes_comments      DROP (idem)
#         - readers_original    -> lectures_qdd   et DROP
#             Pour les deux readers, il faut voir si la donnée existe déjà
#             dans lectures_qdd.
#         - readers_comments    -> lectures_qdd   et DROP
# Le plus simple, c'est de partir des données online et de les traiter ici
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_icdocuments.sql"`
values = []
COLUMNS_ICDOC = [:id, :user_id, :icetape_id, :original_name, :time_original, :time_comments, :options, :created_at, :updated_at]
nombre_lectures_creees = 0
db_exec("SELECT * FROM `current_icdocuments`".freeze).each do |ddoc|
  unless ddoc[:readers_original].nil?
    readers_o = ddoc[:readers_original].split(SPACE).collect{|uid|uid.to_i}
  else
    readers_o = []
  end
  unless ddoc[:readers_comments].nil?
    readers_c = ddoc[:readers_comments].split(SPACE).collect{|uid|uid.to_i}
  else
    readers_c = []
  end
  readers = (readers_o + readers_c) - (readers_o & readers_c)
  unless readers.empty?
    # S'il y a des readers (lecteurs), il faut vérifier qu'ils ont déjà
    # une lecture. Sinon, on la créée
    values_new_lectures = []
    readers.each do |uid|
      db_get('lectures_qdd', {user_id:uid, icdocument_id:ddoc[:id]}) || begin
        values_new_lectures << [uid, ddoc[:id], ddoc[:created_at], ddoc[:updated_at]]
      end
    end
    unless values_new_lectures.empty?
      reqlectures = "INSERT INTO `lectures_qdd` (user_id, icdocument_id, created_at, updated_at) VALUES (?, ?, ?, ?)".freeze
      db_exec(reqlectures, values_new_lectures)
      nombre_lectures_creees += values_new_lectures.count
    end
  end
  values << COLUMNS_ICDOC.collect { |prop| ddoc[prop] }
end
puts "Nombre de lectures créées : #{nombre_lectures_creees}".vert
# On peut injecter toutes les données dans icdocuments
unless values.empty?
  db_exec('TRUNCATE `icdocuments`')
  interro = Array.new(COLUMNS_ICDOC.count, '?').join(VG)
  request = "INSERT INTO `icdocuments` (#{COLUMNS_ICDOC.join(VG)}) VALUES (#{interro})".freeze
  db_exec(request, values)
  puts "🗄️ Dumping des icdocuments opéré avec succès".vert
end
db_exec("DROP TABLE `current_icdocuments`".freeze)

# On peut exporter la table lectures_qdd
`mysqldump -u root icare lectures_qdd > "#{FOLDER_GOODS_SQL}/lectures_qdd.sql"`
puts "🗄️ Dumping des lectures_qdd opéré avec succès".vert
db_exec("DROP TABLE `current_lectures_qdd`".freeze)
