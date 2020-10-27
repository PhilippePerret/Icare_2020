# encoding: UTF-8
# frozen_string_literal: true

TESTS = File.exists?('./TESTS_ON') # réglé par spec_helper.rb
TEST_MODE = TESTS === true

ONLINE  = ENV['ONLINE'] != "false" unless defined?(ONLINE)
OFFLINE = !ONLINE

DB_NAME = TEST_MODE ? 'icare_test' : 'icare_db'
