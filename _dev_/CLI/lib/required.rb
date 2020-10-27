# encoding: UTF-8
=begin
  Requis pour la ligne de commande
=end
# require 'rubygems'
require 'tty-prompt'
require './_lib/required/__first/extensions/Formate_helpers'


Q = TTY::Prompt.new

LIB_FOLDER = File.join(APP_FOLDER, '_lib') # NOTE ATTENTION : celui du site
DEV_FOLDER = File.join(APP_FOLDER, '_dev_')
REQUIRED_FOLDER = File.join(CLI_FOLDER,'lib','required')
COMMANDS_FOLDER = File.join(CLI_FOLDER,'lib','commands')

FOLD_REL_PAGES = './_lib/_pages_'

Dir["#{REQUIRED_FOLDER}/**/*.rb"].each do |m|
  require m
end
