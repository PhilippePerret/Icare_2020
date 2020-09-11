#!/usr/bin/ruby
# encoding: UTF-8
# frozen_string_literal: true
begin
  require './_lib/required'
  App.run
  # Note : Le programme ne passera jamais par ici
rescue Exception => e
  ERROR = e
  File.open('./fatal_errors.log','wb') do |f|
    f.puts "Ruby version : #{Gem.ruby_version.version}"
    f.puts "Gem dir : #{Gem.dir}"
    f.puts "Gem default_dir : #{Gem.default_dir}"
    f.write("#{Time.now} --- FATAL ERROR:\n    #{e.message}\n    #{e.backtrace.join("\n    ")}")
  end rescue nil
  send_error(e) rescue nil
  require "#{FOLD_REL_PAGES}/errors/systemique"
end
###############!/usr/bin/env ruby
##########!/Users/philippeperret/.rbenv/versions/2.6.3/bin/ruby
