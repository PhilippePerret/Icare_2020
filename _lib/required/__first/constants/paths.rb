# encoding: UTF-8
# frozen_string_literal: true
=begin
  Constantes

  Note : d'autres constante peuvent être définies dans le fichier /config.rb
=end
LIB_FOLDER      = File.expand_path('./_lib') unless defined?(LIB_FOLDER)
APP_FOLDER      = File.dirname(LIB_FOLDER) unless defined?(APP_FOLDER)
PAGES_FOLDER    = File.join(LIB_FOLDER,'_pages_') unless defined?(PAGES_FOLDER)
FOLD_REL_PAGES = './_lib/_pages_' unless defined?(FOLD_REL_PAGES)
PROCESSUS_WATCHERS_FOLDER = File.join(LIB_FOLDER,'_watchers_processus_')
DATA_FOLDER     = File.join(LIB_FOLDER,'data') unless defined?(DATA_FOLDER)
MODULES_FOLDER  = File.join(LIB_FOLDER,'modules')
TEMP_FOLDER     = File.join(APP_FOLDER,'tmp')
FORMS_FOLDER    = File.join(TEMP_FOLDER,'forms')
LOGS_FOLDER     = File.join(TEMP_FOLDER,'logs')
DOWNLOAD_FOLDER = File.join(TEMP_FOLDER,'downloads')
QDD_FOLDER      = File.join(DATA_FOLDER, 'qdd')
PUBLIC_FOLDER   = File.join(APP_FOLDER, 'public')

# Les dossiers à construire, le cas échéant
# Note : on pourrait supprimer ces lignes après un certain temps
[FORMS_FOLDER, DOWNLOAD_FOLDER, LOGS_FOLDER].each do |dossier|
  `mkdir -p "#{dossier}"`  unless File.exists?(dossier)
end

require File.join(DATA_FOLDER,'secret','mysql') # => DATA_MYSQL
