# encoding: UTF-8
# frozen_string_literal: true
require 'fileutils'

puts "Essai…"
puts "dossier : #{File.expand_path('./img')}"
nombre = 0
Dir["./img/**/*"].each do |fpath|
  next if not File.directory?(fpath)
  next if not fpath.end_with?(/\-(small|big|regular|large|bigger|huge)/)
  # FileUtils.rm_rf(fpath)
  puts "DELETE #{fpath}"
  nombre += 1
end

puts "Nombre de dossiers détruits : #{nombre}"
