# encoding: UTF-8
=begin
  Requis pour tout le déploiement
=end
THISFOLDER = File.dirname(__FILE__) 

FOLDER_GOODS_SQL = '/Users/philippeperret/Sites/AlwaysData/xbackups/Goods_for_2020'.freeze
FOLDER_CURRENT_ONLINE = '/Users/philippeperret/Sites/AlwaysData/xbackups/Version_current_online'.freeze

SERVEUR_SSH = "icare@ssh-icare.alwaysdata.net".freeze

Dir["#{THISFOLDER}/required/**/*.rb"].each{|m| require m}
