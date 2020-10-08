# encoding: UTF-8
=begin
  Pour effectuer des réparations rapides sur la base de données distantes.
=end
ONLINE = true
require_relative './scripts/required'
MyDB.DBNAME = 'icare_db'
MyDB.online = true

request = <<-SQL
-- Ici la requête --
SQL
puts db_exec(request)
