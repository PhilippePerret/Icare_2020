# encoding: UTF-8
# frozen_string_literal: true
=begin
  Requis pour tout le déploiement
=end
require 'fileutils'

THISFOLDER = __dir__ # File.dirname(__FILE__)
puts "THISFOLDER: #{THISFOLDER}"

ALWAYSDATA_FOLDER       = '/Users/philippeperret/Sites/AlwaysData'
ICARE_FOLDER            = File.join(ALWAYSDATA_FOLDER, 'Icare_2020')
FOLDER_GOODS_SQL        = File.join(ALWAYSDATA_FOLDER,'xbackups','Goods_for_2020')
FOLDER_CURRENT_ONLINE   = File.join(ALWAYSDATA_FOLDER,'xbackups','Version_current_online')

SERVEUR_SSH = "icare@ssh-icare.alwaysdata.net"

# Dir["#{THISFOLDER}/required/**/*.rb"].each{|m| require m}
require './_dev_/__DEPLOIEMENT__/xlib/utils'
require './_lib/required'
require './_dev_/CLI/lib/required/String' # notamment pour les couleur
require './_lib/data/secret/mysql' # => DATA_MYSQL
