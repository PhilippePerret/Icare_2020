# encoding: UTF-8
=begin
  Requis pour tout le déploiement
=end
require 'fileutils'

THISFOLDER = File.dirname(__FILE__)

ALWAYSDATA_FOLDER       = '/Users/philippeperret/Sites/AlwaysData'.freeze
ICARE_FOLDER            = File.join(ALWAYSDATA_FOLDER, 'Icare_2020').freeze
FOLDER_GOODS_SQL        = File.join(ALWAYSDATA_FOLDER,'xbackups','Goods_for_2020').freeze
FOLDER_CURRENT_ONLINE   = File.join(ALWAYSDATA_FOLDER,'xbackups','Version_current_online').freeze

SERVEUR_SSH = "icare@ssh-icare.alwaysdata.net".freeze

Dir["#{THISFOLDER}/required/**/*.rb"].each{|m| require m}

require './_lib/required'
require './_dev_/CLI/lib/required/String' # notamment pour les couleur
require './_lib/data/secret/mysql' # => DATA_MYSQL
