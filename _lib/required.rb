# encoding: UTF-8
=begin
  L'appel à 'route' va bloquer le module. Il faut mettre
  SELF_LOADED à true dans le module appelant pour que cela n'arrive pas.
=end
SELF_LOADED = false unless defined?(SELF_LOADED)

require 'rubygems'
require 'json'
require 'cgi'
require 'cgi/session'
require 'mysql2'
require 'erb'
require 'yaml'

LIB_FOLDER  = File.dirname(__FILE__)
TESTS       = File.exists?('./TESTS_ON') # réglé par spec_helper.rb

require_relative 'required/__first/constants/paths'

# Le fichier de configuration
require './config'


Dir["#{LIB_FOLDER}/required/__first/**/*.rb"].each{|m|require m}
Dir["#{LIB_FOLDER}/required/_classes/**/*.rb"].each{|m|require m}
Dir["#{LIB_FOLDER}/required/then/**/*.rb"].each{|m|require m}

if not String.respond_to?(:match?)
  Dir["#{LIB_FOLDER}/xtra_old_ruby_versions/**/*.rb"].each{|m|require m}
end

# log("ENV : #{ENV.inspect}") rescue nil
# log("Version ruby #{RUBY_VERSION}")
# log("ONLINE: #{ONLINE.inspect} (OFFLINE est #{OFFLINE.inspect})")
# log("DATABASE: #{MyDB.DBNAME.inspect}")
# log("ENV['REMOTE_ADDR'] = #{ENV['REMOTE_ADDR'].inspect}")
# log("TESTS : #{TESTS.inspect}")
unless SELF_LOADED
  log("ROUTE : #{route.to_s}")
  # On trace ce chargement
  trace(id:"LOADING", message:route.to_s,data:Tracer.params_added())
end

# Pour le concours de synopsis
require './_lib/_pages_/concours/xrequired/Concours_mini.rb'

# NOTE Dans ce required.rb, user n'est pas encore défini. Il le sera seulement
# dans User.init appelé par App.init
