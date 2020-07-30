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
APP_FOLDER = File.dirname(File.dirname(File.dirname(File.dirname(__FILE__))))
log("[Ajax] APP_FOLDER = #{APP_FOLDER.inspect}")
require_relative 'ajax_class'

log("Chargement des modules")
Dir["#{APP_FOLDER}/ajax/ajax/required/**/*.rb"].each do |m|
  log("[Ajax] Chargement module '#{m}'")
  require m
end


Dir.chdir(APP_FOLDER) do
  # Le module pour gérer les sessions
  require './_lib/required/_classes/Session' # => Session
  # Le module pour gérer les UUID
  require './_lib/required/__first/unique_usage_ids' # => UUID
end
