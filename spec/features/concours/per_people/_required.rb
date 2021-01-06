# encoding: UTF-8
# frozen_string_literal: true
require_relative '../_required'

Dir["#{__dir__}/xlib/**/*.rb"].each{|m|require m}
Dir["#{__dir__}/_it_cases_/**/*.rb"].each{|m|require m}
