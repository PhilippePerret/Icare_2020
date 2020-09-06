# encoding: UTF-8
=begin
  Pour requérir toutes les librairies utiles
=end
require 'yaml'

APP_FOLDER = File.dirname(__dir__)
LIB_FOLDER = File.join(APP_FOLDER,'xlib')

Dir["#{LIB_FOLDER}/_required/_first/**/*.rb"].each{|m|require(m)}
Dir["#{LIB_FOLDER}/_required/_then/**/*.rb"].each{|m|require(m)}
