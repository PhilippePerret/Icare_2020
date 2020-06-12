# encoding: UTF-8
require 'json'
require 'cgi'
require 'cgi/session'
require 'mysql2'
require 'erb'
require 'yaml'

LIB_FOLDER      = File.dirname(__FILE__)

require_relative 'required/__first/constants/paths'

# Le fichier de configuration
require './config'

Dir["#{LIB_FOLDER}/required/__first/**/*.rb"].each{|m|require m}
Dir["#{LIB_FOLDER}/required/_classes/**/*.rb"].each{|m|require m}
Dir["#{LIB_FOLDER}/required/then/**/*.rb"].each{|m|require m}

TESTS = File.exists?('./TESTS_ON') # réglé par spec_helper.rb
log("TESTS : #{TESTS.inspect}")

log("ROUTE : #{route.to_s}")
