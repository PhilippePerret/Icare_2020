# encoding: UTF-8
# frozen_string_literal: true

CRON_LIB_FOLDER   = File.join(CRON_FOLDER,'_lib')
APPFOLDER         = File.dirname(CRON_FOLDER)

ONLINE = ENV['ONLINE'] != "false"

# Les modules du site utiles pour le cron
Dir.chdir(APPFOLDER) do
  require './_lib/required/__first/extensions/Formate_helpers'
  require './_lib/required/__first/Date_utils'
  require './_lib/required/__first/require_methods'
  require './_lib/required/__first/extensions/String'
  require './_lib/required/__first/helpers/string_helpers_module'
  require './_lib/required/__first/feminines' # => FemininesMethods
  require './_lib/required/__first/db'
end

Dir["#{CRON_LIB_FOLDER}/_required/_first/**/*.rb"].each{|m| require m}
Dir["#{CRON_LIB_FOLDER}/_required/_then/**/*.rb"].each{|m| require m}
require_relative './_required/post_constants'

# Réglage du serveur de données
SANDBOX = ONLINE ? false : true unless defined?(SANDBOX)
MyDB.DBNAME = DB_NAME
