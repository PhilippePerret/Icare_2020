# encoding: UTF-8
# frozen_string_literal: true
require_relative '../_required'
require_relative './_it_cases_generaux'

Dir["#{__dir__}/_it_cases_/**/*.rb"].each{|m|require m}
