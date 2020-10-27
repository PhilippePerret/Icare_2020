#!/usr/bin/env ruby
# encoding: UTF-8
# frozen_string_literal: true

# Première constantes utiles
CRON_FOLDER = File.expand_path(__dir__)

begin
  require_relative './_lib/_required'
  Dir.chdir(APPFOLDER) do
    Cronjob.run
  end
rescue Exception => e
  puts "FATAL ERROR: #{e.message}"
  puts e.backtrace.join("\n")
end
