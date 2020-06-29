# encoding: UTF-8
=begin
  Constantes

  Note : d'autres constante peuvent être définies dans le fichier /config.rb
=end


ONLINE  = ENV['HTTP_HOST'] != "localhost"
OFFLINE = !ONLINE
DB_NAME       = 'icare'
DB_TEST_NAME  = 'icare_test'

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

MAIN_LINKS = {
  home:       '<a href="home">atelier icare</a>'.freeze,
  overview:   '<a href="overview/home"><span class="emoji">👀</span> <span>en savoir plus</span></a>'.freeze,
  overview_s: '<a href="overview/home">en savoir plus</a>'.freeze,
  signup:     '<a id="signup-btn" href="user/signup" class="main">📋 s’inscrire</a>'.freeze,
  signup_s:   '<a id="signup-btn" href="user/signup" class="main">s’inscrire</a>'.freeze,
  login:      '<a href="user/login">🔓 s’identifier</a>'.freeze,
  login_s:    '<a href="user/login">s’identifier</a>'.freeze,
  logout:     '<a class="btn-logout" href="user/logout">🔒 se déconnecter</a>'.freeze,
  logout_s:   '<a class="btn-logout" href="user/logout">se déconnecter</a>'.freeze,
  # BUREAU
  bureau:     '<a href="bureau/home">bureau</a>'.freeze,
  bureau_s:   '<a href="bureau/home">bureau</a>'.freeze,
  work:       '<a href="bureau/travail">Travail courant</a>'.freeze,
  notices:    '<a href="bureau/notifications">Notifications%{non_vus}</a>'.freeze,
  admin_notifications:  '<a href="admin/notifications">Notifications%{non_vus}</a>'.freeze,
  frigo:      '<a href="bureau/frigo">🌡️ Porte de frigo%{non_vus}'.freeze,
  # DIVERS
  aide:       '<a href="aide/home"><span class="emoji">🚨</span><span>aide</span></a>'.freeze,
  aide_s:     '<a href="aide/home">aide</a>'.freeze,
  contact:    '<a href="contact/mail"><span class="emoji">📧</span><span>contact</span></a>'.freeze,
  contact_s:  '<a href="contact/mail">contact</a>'.freeze,
  plan:       '<a href="plan" class="btn small"><span class="emoji">📍</span>PLAN</a>'.freeze,
  plan_s:     '<a href="plan">plan</a>'.freeze,
  qdd:        '<a href="qdd/home"><span class="emoji">🗄</span>️Quai Des Docs</a>'.freeze
}
