# encoding: UTF-8
# frozen_string_literal: true
=begin
  Premier module de traitement de la table des lectures QdD
  (gros changements)
=end
CLECTURES_COLS = [:id, :user_id, :icdocument_id, :cotes, :comments, :created_at, :updated_at]
LECTURES_COLUMNS = [:user_id, :icdocument_id, :comments, :created_at, :updated_at, :cote_original, :cote_comments]

TableGetter.import('lectures_qdd')

request = <<-SQL.strip
DROP TABLE IF EXISTS `lectures_qdd`;
CREATE TABLE `lectures_qdd` (
  icdocument_id   INT(11) NOT NULL,
  user_id         INT(11) NOT NULL,
  cote_original   TINYINT,
  cote_comments   TINYINT,
  comments        TEXT,
  created_at      VARCHAR(10) DEFAULT NULL,
  updated_at      VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY(icdocument_id, user_id)
);
SQL
db_exec(request)
success("#{TABU}Création intégrale de la table lectures_qdd")

# On récupère et on traite les cotes
values = []
db_exec("SELECT #{CLECTURES_COLS.join(VG)} FROM `current_lectures_qdd`").each do |dlecture|
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
  request = "INSERT INTO `lectures_qdd` (#{LECTURES_COLUMNS.join(VG)}) VALUES (#{interro})"
  db_exec(request, values)
  success("#{TABU}Insertion des lectures dans lectures_qdd")
end
