# encoding: UTF-8
require 'fileutils'

def cgi
  @cgi ||= CGI.new('html4')
end

def user
  @user ||= User.get(Ajax.param(:__uid) || 0)
end #/ user

# Le dossier de l'application
# ---------------------------
# Contient quelque chose comme '/Users/moi/Sites/MonApplication'
#
APP_FOLDER = File.dirname(File.dirname(File.dirname(__dir__)))
log("[Ajax] APP_FOLDER = #{APP_FOLDER.inspect}")
require_relative 'ajax_class'

log("=> Chargement des modules")
Dir["#{APP_FOLDER}/ajax/ajax/required/**/*.rb"].each do |m|
  log("[Ajax] Chargement module '#{m}'")
  require m
end
log("<= Chargement des modules")

log("ENV['HTTP_HOST'] = #{ENV['HTTP_HOST'].inspect}")
OFFLINE = ENV['HTTP_HOST'] == 'localhost'
ONLINE  = !OFFLINE
TEST_ON = File.exists?('../../TESTS_ON')
DATABASE = ONLINE ? 'icare_db' : 'icare_test'
log("DATABASE = #{DATABASE}")
erreur_required = nil
Dir.chdir(APP_FOLDER) do
  begin
    # Le module pour gérer les sessions
    require './_lib/required/__first/db'
    MyDB.DBNAME = DATABASE
    require './_lib/required/_classes/Session' # => Session
    require './_lib/required/__first/unique_usage_ids' # => UUID
  rescue Exception => e
    erreur_required = e
  end
end
if erreur_required
  log("# ERREUR : #{erreur_required.message}")
  log(erreur_required.backtrace.join(RC))
end
