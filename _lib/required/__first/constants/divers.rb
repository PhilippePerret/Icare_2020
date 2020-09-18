# encoding: UTF-8
# frozen_string_literal: true

ONLINE  = ENV['HTTP_HOST'] != "localhost" unless defined?(ONLINE)
OFFLINE = !ONLINE
DB_NAME         = ONLINE ? 'icare_db' : 'icare'
DB_TEST_NAME    = 'icare_test'
