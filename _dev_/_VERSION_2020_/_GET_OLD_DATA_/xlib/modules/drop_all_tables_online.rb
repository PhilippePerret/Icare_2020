# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module qui détruit toutes les tables de la base icare_db distante
=end
ONLINE = true
MyDB.DBNAME = 'icare_db'
drop_lines = db_exec("SHOW TABLES;").collect do |dtable|
  tbname = dtable.values.first
  "DROP TABLE `#{tbname}`;"
end
request = <<-SQL
START TRANSACTION;
#{drop_lines.join(RC)}
COMMIT;
SQL
db_exec(request)
