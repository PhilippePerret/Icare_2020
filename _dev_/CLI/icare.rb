#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  icare en ligne de commande
  Pour le moment, c'est un simple bricolage
=end
require_relative 'lib/required'
begin
  Dir.chdir(APP_FOLDER) do
    IcareCLI.analyse_command
    IcareCLI.run
  end
rescue Exception => e
  puts "ERREUR: #{e.message}".rouge
  # puts e.backtrace.join("\n")
end
