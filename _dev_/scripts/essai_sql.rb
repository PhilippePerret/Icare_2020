require_relative 'required'

MyDB.DBNAME = 'icare'
req = <<-SQL
SELECT
  doc.id, icet.id AS icetape, doc.icetape_id,
  abset.id AS absetape, absmod.id AS absmodule,
  lect.cotes AS pertinence
  FROM icdocuments AS doc
  INNER JOIN icetapes AS icet ON doc.icetape_id = icet.id
  INNER JOIN absetapes AS abset ON abset.id = icet.absetape_id
  INNER JOIN absmodules AS absmod ON absmod.id = abset.absmodule_id
  -- Tentative pour la pertinence
  INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
  LIMIT 20;
SQL

db_exec(req)&.each do |res|
  puts res.inspect
end
puts "ERREUR MYSQL: #{MyDB.error.inspect}" if MyDB.error
