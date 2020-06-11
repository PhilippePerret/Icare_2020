#!/usr/bin/env ruby
# encoding: UTF-8
=begin
  icare en ligne de commande
  Pour le moment, c'est un simple bricolage
=end
require_relative 'lib/required'
begin
  IcareCLI.analyse_command
  IcareCLI.run
rescue Exception => e
  puts "ERREUR: #{e.message}"
  # puts e.backtrace.join("\n")
end