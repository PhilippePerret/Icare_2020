#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  icare en ligne de commande
=end
CLI_FOLDER = File.dirname(__FILE__)
APP_FOLDER = File.dirname(File.dirname(CLI_FOLDER))
begin
  Dir.chdir(APP_FOLDER) do
    require './_dev_/CLI/lib/required'
    IcareCLI.analyse_command
    IcareCLI.run
  end
rescue Exception => e
  msg = "ERREUR: #{e.message}"
  msg = msg.rouge if String.respond_to?(:rouge)
  puts msg
  puts e.backtrace.join("\n")
end
