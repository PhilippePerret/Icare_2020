# encoding: UTF-8
# frozen_string_literal: true
UI_TEXTS  = {} unless defined?(UI_TEXTS)
MESSAGES  = {} unless defined?(MESSAGES)
ERRORS    = {} unless defined?(ERRORS)
Dir["#{__dir__}/required/**/*.rb"].each{|m|require m}
