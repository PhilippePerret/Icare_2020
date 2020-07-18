# encoding: UTF-8
=begin
  Requis en tout premier
=end

ONLINE  = ENV['HTTP_HOST'] != "localhost"
OFFLINE = !ONLINE

# Requérir tout le dossier des requis
Dir["#{CRON_FOLDER}/_lib/_required/**/*.rb"].each { |m| require m }

# On requiert quelques classes du site
[
  './_lib/required/__first/db'
].each do |m|
  require m
end

MyDB.DBNAME = ONLINE ? 'icare_db' : 'icare'
