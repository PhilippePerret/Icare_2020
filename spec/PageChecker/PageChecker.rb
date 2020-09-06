#!/usr/bin/env ruby -U
# encoding: UTF-8
=begin
  Module principal de PageChecker
  Il doit être appelé en ligne de commande
=end
begin
  require_relative 'xlib/_required'
  PageChecker.run
rescue Exception => e
  puts "ERREUR FATALE : #{e.message}"
  puts e.backtrace.join(RC)
end
