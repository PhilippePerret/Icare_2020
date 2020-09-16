# encoding: UTF-8
# frozen_string_literal: true
=begin
  Traitement des documents
=end

# Les colonnes finales
COLUMNS_ICDOC = [:id, :user_id, :icetape_id, :original_name, :time_original, :time_comments, :options, :created_at, :updated_at]

TableGetter.import('icdocuments')

# Pour connaitre le nombre de lectures qui seront créées (lectures_qdd)
nombre_lectures_creees = 0
# Pour mettre les données des icdocuments
values = []

db_exec("SELECT * FROM `current_icdocuments`").each do |ddoc|
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
      reqlectures = "INSERT INTO `lectures_qdd` (user_id, icdocument_id, created_at, updated_at) VALUES (?, ?, ?, ?)"
      db_exec(reqlectures, values_new_lectures)
      nombre_lectures_creees += values_new_lectures.count
    end
  end
  values << COLUMNS_ICDOC.collect { |prop| ddoc[prop] }
end
success("#{TABU}Nombre de lectures créées : #{nombre_lectures_creees}.")

request = <<-SQL
START TRANSACTION;
TRUNCATE `icdocuments`;
ALTER TABLE `icdocuments`
  MODIFY COLUMN `time_original` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `time_comments` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `created_at` VARCHAR(10) DEFAULT NULL,
  MODIFY COLUMN `updated_at` VARCHAR(10) DEFAULT NULL;
COMMIT;
SQL
db_exec(request)
# Injection des données
interro = Array.new(COLUMNS_ICDOC.count, '?').join(VG)
request = "INSERT INTO `icdocuments` (#{COLUMNS_ICDOC.join(VG)}) VALUES (#{interro})"
db_exec(request, values)
TableGetter.export('icdocuments')
TableGetter.export('lectures_qdd')
