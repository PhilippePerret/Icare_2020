# encoding: UTF-8
SELF_LOADED = false unless defined?(SELF_LOADED)

puts "-> required" if SELF_LOADED
require 'rubygems'
require 'json'
require 'cgi'
require 'cgi/session'
require 'mysql2'
require 'erb'
require 'yaml'

LIB_FOLDER = File.dirname(__FILE__)

require_relative 'required/__first/constants/paths'

# Le fichier de configuration
require './config'


puts "-> avant lib 1" if SELF_LOADED

Dir["#{LIB_FOLDER}/required/__first/**/*.rb"].each{|m|require m}
Dir["#{LIB_FOLDER}/required/_classes/**/*.rb"].each{|m|require m}
Dir["#{LIB_FOLDER}/required/then/**/*.rb"].each{|m|require m}

puts "-> après lib 1" if SELF_LOADED

if not String.respond_to?(:match?)
  Dir["#{LIB_FOLDER}/xtra_old_ruby_versions/**/*.rb"].each{|m|require m}
end

puts "-> avant les logs" if SELF_LOADED

log("Version ruby #{RUBY_VERSION}")
log("ONLINE: #{ONLINE.inspect} (OFFLINE est #{OFFLINE.inspect})")
log("DATABASE: #{MyDB.DBNAME.inspect}")
log("ENV['REMOTE_ADDR'] = #{ENV['REMOTE_ADDR'].inspect}")

puts "-> avant la trace" if SELF_LOADED

# On trace ce chargement
trace(id:"LOADING", message:route.to_s,data:Tracer.params_added()) unless SELF_LOADED

puts "<- après la trace" if SELF_LOADED

TESTS = File.exists?('./TESTS_ON') # réglé par spec_helper.rb
log("TESTS : #{TESTS.inspect}")
log("ROUTE : #{route.to_s}") unless SELF_LOADED

# NOTE Dans ce required.rb, user n'est pas encore défini. Il le sera seulement
# dans User.init appelé par App.init


puts "<- required" if SELF_LOADED
