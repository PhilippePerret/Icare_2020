# encoding: UTF-8
=begin
  Traitement de la table des lectures QDD
  De nombreuses modifications sont nécessaires
=end
puts "Conformisation des lectures du Quai des docs…".bleu
# lectures_qdd
# ------------
#     Synopsis
#       - récupérer les données online
#       - dispatcher 'cotes' dans 'cote_original' (1er chiffre-string) et 'cote_comments' (2nd chiffre-string)
#       - garder toutes les autres colonnes, même comments qui en contient quelques uns
#       - exporter seulement quand icdocuments sera passé par là.
`mysql -u root icare < "#{FOLDER_CURRENT_ONLINE}/current_lectures_qdd.sql"`
db_exec(<<-SQL.strip.freeze)
DROP TABLE IF EXISTS `lectures_qdd`;
CREATE TABLE `lectures_qdd` (
  icdocument_id   INT(11) NOT NULL,
  user_id         INT(11) NOT NULL,
  cote_original   TINYINT,
  cote_comments   TINYINT,
  comments        TEXT,
  created_at      INT(10) DEFAULT NULL,
  updated_at      INT(10) DEFAULT NULL,
  PRIMARY KEY(icdocument_id, user_id)
);
SQL
if MyDB.error
  puts "SQL ERROR : #{MyDB.error.inspect}".rouge
  exit
end
values = []
CLECTURES_COLS = [:id, :user_id, :icdocument_id, :cotes, :comments, :created_at, :updated_at]
LECTURES_COLUMNS = [:user_id, :icdocument_id, :comments, :created_at, :updated_at, :cote_original, :cote_comments]
db_exec("SELECT #{CLECTURES_COLS.join(VG)} FROM `current_lectures_qdd`".freeze).each do |dlecture|
  unless dlecture[:cotes]
    cote_original, cote_comments = dlecture.delete(:cotes).split(EMPTY_STRING)
    cote_original = cote_original == '-' ? nil : cote_original.to_i
    cote_comments = cote_comments == '-' ? nil : cote_comments.to_i
    dlecture.merge!(cote_original:cote_original, cote_comments:cote_comments)
  end
  values << LECTURES_COLUMNS.collect { |prop| dlecture[prop] }
end
unless values.empty?
  interro = Array.new(LECTURES_COLUMNS.count, '?').join(VG)
  request = "INSERT INTO `lectures_qdd` (#{LECTURES_COLUMNS.join(VG)}) VALUES (#{interro})".freeze
  db_exec(request, values)
end
# NOTE Ne pas exporter avant d'avoir traité icdocuments, qui peut aussi
# créer des lectures
puts "Note : on n'exportera plus tard, après avoir traité les icdocuments".jaune
