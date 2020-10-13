# encoding: UTF-8
require 'fileutils'

def require_folder(path)
  log("++ REQUÉRIR DOSSIER : #{path}")
  Dir["#{path}/**/*.rb"].each do |mod|
    log("---> Module #{mod}")
    require mod
  end
end #/ require_folder

def cgi
  @cgi ||= CGI.new('html4')
end

def user
  @user ||= begin
    if Ajax.param(:__uid)
      log("Ajax.param(:__uid) = #{Ajax.param(:__uid).inspect}")
      require "#{APP_FOLDER}/_lib/required/__first/ContainerClass_definition"
      require_folder(File.join(APP_FOLDER,'_lib','required','_classes','_User'))
      User.get(Ajax.param(:__uid) || 0)
    end
  end
end #/ user

# Le dossier de l'application
# ---------------------------
# Contient quelque chose comme '/Users/moi/Sites/MonApplication'
#
APP_FOLDER = File.dirname(File.dirname(File.dirname(__dir__)))
log("[Ajax] APP_FOLDER = #{APP_FOLDER.inspect}")
require_relative 'ajax_class'

log("=> Chargement des modules requis")
require_folder("#{APP_FOLDER}/_lib/ajax/ajax/required")
log("<= Chargement des modules requis")

log("ENV['HTTP_HOST'] = #{ENV['HTTP_HOST'].inspect}")
OFFLINE = ENV['HTTP_HOST'] == 'localhost'
ONLINE  = !OFFLINE
TEST_ON = File.exists?('../../TESTS_ON')
DATABASE = ONLINE ? 'icare_db' : 'icare_test'
log("DATABASE = #{DATABASE}")
erreur_required = nil
Dir.chdir(APP_FOLDER) do
  begin
    require './_lib/required/__first/constants/String'
    require './_lib/required/__first/db'
    MyDB.DBNAME = DATABASE
    # Le module pour gérer les sessions
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
