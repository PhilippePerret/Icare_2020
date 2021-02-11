# encoding: UTF-8
# frozen_string_literal: true
require_relative '../_required'

require_support('concours')

require './_lib/_pages_/concours/espace_concurrent/constants'

Dir["#{__dir__}/xlib/required/**/*.rb"].each{|m|require m}
Dir["#{__dir__}/_it_cases_/**/*.rb"].each{|m|require m}
