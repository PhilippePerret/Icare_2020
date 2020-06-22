require_relative 'required'

MyDB.DBNAME = 'icare'
# req = <<-SQL
# SELECT
#   doc.id, icet.id AS icetape, doc.icetape_id,
#   abset.id AS absetape, absmod.id AS absmodule,
#   lect.cotes AS pertinence
#   FROM icdocuments AS doc
#   INNER JOIN icetapes AS icet ON doc.icetape_id = icet.id
#   INNER JOIN absetapes AS abset ON abset.id = icet.absetape_id
#   INNER JOIN absmodules AS absmod ON absmod.id = abset.absmodule_id
#   -- Tentative pour la pertinence
#   INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
#   LIMIT 20;
# SQL

req = <<-SQL
SELECT
  icdocument_id,
  SUM(cote_original) AS pertinence_original,
  SUM(cote_comments) AS pertinence_comments
  FROM lectures_qdd
  GROUP BY icdocument_id
SQL

req = <<-SQL
SELECT
  lect.icdocument_id,
  AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
  FROM icdocuments AS doc
  INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
  GROUP BY lect.icdocument_id
  ORDER BY pertinence DESC
SQL

req = <<-SQL
SELECT
  doc.id, doc.original_name, doc.user_id, doc.options,
  doc.updated_at, doc.time_original, doc.time_comments,
  doc.icetape_id,
  abset.id AS absetape_id,
  lect.icdocument_id,
  AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
  FROM icdocuments AS doc
  INNER JOIN icetapes AS icet ON doc.icetape_id = icet.id
  INNER JOIN absetapes AS abset ON abset.id = icet.absetape_id
  INNER JOIN absmodules AS absmod ON absmod.id = abset.absmodule_id
  INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
  WHERE #{wheres.join(' AND ')}
  GROUP BY lect.icdocument_id
  ORDER BY #{sortedkey}
SQL

db_exec(req)&.each do |res|
  puts res.inspect
end
puts "ERREUR MYSQL: #{MyDB.error.inspect}" if MyDB.error
