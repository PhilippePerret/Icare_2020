# encoding: UTF-8
=begin
  Constantes

  Note : d'autres constante peuvent être définies dans le fichier /config.rb
=end


ONLINE  = ENV['HTTP_HOST'] != "localhost"
OFFLINE = !ONLINE
DB_NAME       = 'icare'
DB_TEST_NAME  = 'icare_test'

LIB_FOLDER      = File.dirname(__FILE__)
APP_FOLDER      = File.dirname(LIB_FOLDER)
PAGES_FOLDER    = File.join(LIB_FOLDER,'pages')
DATA_FOLDER     = File.join(LIB_FOLDER,'data')
MODULES_FOLDER  = File.join(LIB_FOLDER,'modules')
TEMP_FOLDER     = File.join(LIB_FOLDER,'tmp')
FORMS_FOLDER    = File.join(TEMP_FOLDER,'forms')
LOGS_FOLDER     = File.join(TEMP_FOLDER,'logs')

`mkdir -p "#{FORMS_FOLDER}"`
`mkdir -p "#{LOGS_FOLDER}"`

require File.join(DATA_FOLDER,'secret','mysql') # => DATA_MYSQL
