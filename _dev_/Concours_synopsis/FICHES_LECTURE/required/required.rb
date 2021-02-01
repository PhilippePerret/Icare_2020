# encoding: UTF-8
# frozen_string_literal: true

FL_FOLDER = File.dirname(__dir__)
FL_MODULES_FOLDER = File.join(FL_FOLDER,'modules')
Dir["#{__dir__}/required_first/**/*.rb"].each { |m| require m }
Dir["#{__dir__}/required_then/**/*.rb"].each { |m| require m }
