# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour charger les librairies nécessaires
=end
require 'json'

TESTS = File.exists?('./TESTS_ON') || ENV['TESTS_ON'] == true
puts "TESTS : #{TESTS.inspect} (ENV['TESTS_ON'] = #{ENV['TESTS_ON'].inspect})"

require './_lib/required/__first/ContainerClass_definition' #  => ContainerClass
require './_lib/required/__first/db'  # => MyDB
require './_lib/required/__first/extensions/Formate_helpers' # formate_date
require './_lib/required/__first/extensions/Time'

Dir["#{__dir__}/required/_first/**/*.rb"].each { |m| require(m) }
Dir["#{__dir__}/required/_then/**/*.rb"].each { |m| require(m) }
