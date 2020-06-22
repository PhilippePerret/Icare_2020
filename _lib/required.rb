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

# On trace ce chargement
data_trace = {message:"LOADING", route:route.to_s}
# S'il y a des params, on les ajoute, mais pas s'ils sont trop longs
unless URL.current.params.nil? || URL.current.params.empty?
  params_json = URL.current.params.to_json
  data_trace.merge!(params: params_json) unless params_json.length > 1000
end
trace(data_trace)

TESTS = File.exists?('./TESTS_ON') # réglé par spec_helper.rb
log("TESTS : #{TESTS.inspect}")

log("ROUTE : #{route.to_s}")
