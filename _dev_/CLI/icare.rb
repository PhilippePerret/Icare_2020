#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  icare en ligne de commande
=end
CLI_FOLDER = File.dirname(__FILE__)
APP_FOLDER = File.dirname(File.dirname(CLI_FOLDER))

# On profite de chaque appel pour détruire les fichier .DS_STORE qui
# peuvent exister dans l'application.
if true
  stores = Dir["#{APP_FOLDER}/**/.DS_Store"]
  stores.each{|f|File.delete(f)}
end

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
