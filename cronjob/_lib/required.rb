# encoding: UTF-8
=begin
  Requis en tout premier
=end

# Requérir tout le dossier des requis
Dir["#{CRON_FOLDER}/_lib/_required/**/*.rb"].each { |m| require m }
