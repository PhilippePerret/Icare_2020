require_relative 'required'

MyDB.DBNAME = 'icare_test'
# MyDB.DBNAME = 'icare'
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

# req = <<-SQL
# SELECT
#   icdocument_id,
#   SUM(cote_original) AS pertinence_original,
#   SUM(cote_comments) AS pertinence_comments
#   FROM lectures_qdd
#   GROUP BY icdocument_id
# SQL

# req = <<-SQL
# SELECT
#   lect.icdocument_id,
#   AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
#   FROM icdocuments AS doc
#   INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
#   GROUP BY lect.icdocument_id
#   ORDER BY pertinence DESC
# SQL

# req = <<-SQL
# SELECT
#   doc.id, doc.original_name, doc.user_id, doc.options,
#   doc.updated_at, doc.time_original, doc.time_comments,
#   doc.icetape_id,
#   abset.id AS absetape_id,
#   lect.icdocument_id,
#   AVG(lect.cote_original) + AVG(lect.cote_comments) AS pertinence
#   FROM icdocuments AS doc
#   INNER JOIN icetapes AS icet ON doc.icetape_id = icet.id
#   INNER JOIN absetapes AS abset ON abset.id = icet.absetape_id
#   INNER JOIN absmodules AS absmod ON absmod.id = abset.absmodule_id
#   INNER JOIN lectures_qdd AS lect ON lect.icdocument_id = doc.id
#   WHERE #{wheres.join(' AND ')}
#   GROUP BY lect.icdocument_id
#   ORDER BY #{sortedkey}
# SQL

# # Pour relever les discussions
# user_id = 1
# req = <<-SQL
# SELECT
#   *
#   FROM `frigo_users` AS fu
#   INNER JOIN `frigo_discussions` AS dis ON dis.id = fu.discussion_id
#   INNER JOIN `users` AS u ON fu.user_id = u.id
#   WHERE fu.user_id = %i
#   ORDER BY dis.created_at DESC
# SQL
# req = req % [user_id]
# puts "REQUEST: #{req}"

# # Pour relever tous les participants à une discussion
# discussion_id = 3
# req = <<-SQL
# SELECT
#   dis.id AS discussion_id, u.pseudo AS owner_pseudo
#   FROM `frigo_discussions` AS dis
#   INNER JOIN `frigo_users` AS fu ON dis.id = fu.discussion_id
#   INNER JOIN `users` AS u ON dis.user_id = u.id
#   WHERE dis.id = %i
#   ORDER BY dis.created_at DESC
# SQL
# req = req % [discussion_id]
# puts "REQUEST: #{req}"

# user_id = 1
# req = <<-SQL
# SELECT
#     COUNT(mes.id)
#   FROM `frigo_messages` AS mes
#   INNER JOIN `frigo_users` AS fu ON fu.discussion_id = mes.discussion_id
#   WHERE
#     fu.user_id = #{user_id}
#     AND mes.created_at > fu.last_checked_at
# SQL

# uid = 11 # Élie
# disid = 2
# req = <<-SQL.freeze
# SELECT COUNT(fm.id)
#   FROM `frigo_messages` AS fm
#   INNER JOIN `frigo_users` AS fu  ON fu.user_id = fm.user_id
#   INNER JOIN `frigo_users` AS fdu ON fdu.discussion_id = fm.discussion_id
#   INNER JOIN `frigo_discussions` AS fd ON fm.discussion_id = fd.id
#   WHERE fm.discussion_id = #{disid}
#     -- Le message doit être plus vieux que le dernier check de l'user
#     AND fm.created_at > fu.last_checked_at
#     -- Le message ne doit pas être le dernier message de la discussion
#     AND fm.id != fd.last_message_id
# SQL

# users_ids = '1, 11, 12'
# req = <<-SQL.freeze
# SELECT COUNT(*)
#   FROM frigo_discussions AS fd
#   INNER JOIN frigo_users AS fu ON fu.discussion_id = fd.id
#   WHERE fu.user_id IN (#{users_ids})
#     AND fu.discussion_id = fd.id
# SQL



res = db_exec(req)
# puts "db_exec(req): #{res.inspect}"
res&.each do |res|
  puts res.inspect
end
puts "ERREUR MYSQL: #{MyDB.error.inspect}" if MyDB.error
