# encoding: UTF-8
=begin
  Requis pour la ligne de commande
=end
require 'tty-prompt'


Q = TTY::Prompt.new

CLI_FOLDER = File.dirname(File.dirname(__FILE__))
APP_FOLDER = File.dirname(File.dirname(CLI_FOLDER))
REQUIRED_FOLDER = File.join(CLI_FOLDER,'lib','required')
# puts "APP_FOLDER: #{APP_FOLDER}"

Dir["#{REQUIRED_FOLDER}/**/*.rb"].each { |m| require m }
