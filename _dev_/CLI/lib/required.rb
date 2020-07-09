# encoding: UTF-8
=begin
  Requis pour la ligne de commande
=end
require 'tty-prompt'


Q = TTY::Prompt.new

LIB_FOLDER = File.join(APP_FOLDER, '_lib') # NOTE ATTENTION : celui du site
REQUIRED_FOLDER = File.join(CLI_FOLDER,'lib','required')
COMMANDS_FOLDER = File.join(CLI_FOLDER,'lib','commands')

Dir["#{REQUIRED_FOLDER}/**/*.rb"].each do |m|
  require m
end
