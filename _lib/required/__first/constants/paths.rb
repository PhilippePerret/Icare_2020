# encoding: UTF-8
=begin
  Constantes

  Note : d'autres constante peuvent être définies dans le fichier /config.rb
=end


ONLINE  = ENV['HTTP_HOST'] != "localhost"
OFFLINE = !ONLINE
DB_NAME         = ONLINE ? 'icare_db' : 'icare'
DB_TEST_NAME    = 'icare_test'

APP_FOLDER      = File.dirname(LIB_FOLDER) unless defined?(APP_FOLDER)
PAGES_FOLDER    = File.join(LIB_FOLDER,'pages'.freeze) unless defined?(PAGES_FOLDER)
PROCESSUS_WATCHERS_FOLDER = File.join(LIB_FOLDER,'_watchers_processus_'.freeze)
DATA_FOLDER     = File.join(LIB_FOLDER,'data'.freeze) unless defined?(DATA_FOLDER)
MODULES_FOLDER  = File.join(LIB_FOLDER,'modules'.freeze)
TEMP_FOLDER     = File.join(APP_FOLDER,'tmp'.freeze)
FORMS_FOLDER    = File.join(TEMP_FOLDER,'forms'.freeze)
LOGS_FOLDER     = File.join(TEMP_FOLDER,'logs'.freeze)
DOWNLOAD_FOLDER = File.join(TEMP_FOLDER,'downloads'.freeze)
QDD_FOLDER      = File.join(DATA_FOLDER, 'qdd'.freeze)
PUBLIC_FOLDER   = File.join(APP_FOLDER, 'public'.freeze)

# Les dossiers à construire, le cas échéant
# Note : on pourrait supprimer ces lignes après un certain temps
[FORMS_FOLDER, DOWNLOAD_FOLDER, LOGS_FOLDER].each do |dossier|
  `mkdir -p "#{dossier}"`  unless File.exists?(dossier)
end

require File.join(DATA_FOLDER,'secret','mysql') # => DATA_MYSQL

require_relative 'emojis'
