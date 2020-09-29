# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour charger les librairies nécessaires
=end
require 'json'

require './_lib/required/__first/ContainerClass_definition' #  => ContainerClass
require './_lib/required/__first/db'  # => MyDB
require './_lib/required/__first/extensions/Formate_helpers' # formate_date

Dir["#{__dir__}/required/_first/**/*.rb"].each { |m| require(m) }
Dir["#{__dir__}/required/_then/**/*.rb"].each { |m| require(m) }
