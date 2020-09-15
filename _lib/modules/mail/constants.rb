# encoding: UTF-8
# frozen_string_literal: true

TEMP_FOLDER = File.expand_path(File.join('.','tmp')) unless defined?(TEMP_FOLDER)
DATA_FOLDER = File.expand_path(File.join('.','_lib','data')) unless defined?(DATA_FOLDER)
MAILS_FOLDER = File.join(TEMP_FOLDER,'mails')
`mkdir -p "#{MAILS_FOLDER}"` unless File.exists?(MAILS_FOLDER)
