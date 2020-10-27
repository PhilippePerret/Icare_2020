# encoding: UTF-8
# frozen_string_literal: true

CRON_LIB_FOLDER   = File.join(CRON_FOLDER,'_lib')
APPFOLDER         = File.dirname(CRON_FOLDER)

# Les modules du site utiles pour le cron
Dir.chdir(APPFOLDER) do
  require './_lib/required/__first/extensions/Formate_helpers'
  require './_lib/required/__first/require_methods'
  require './_lib/required/__first/db'
end

Dir["#{CRON_LIB_FOLDER}/_required/_first/**/*.rb"].each{|m| require m}
Dir["#{CRON_LIB_FOLDER}/_required/_then/**/*.rb"].each{|m| require m}
require_relative './_required/post_constants'
