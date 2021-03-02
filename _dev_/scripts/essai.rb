# encoding: UTF-8
# frozen_string_literal: true
=begin
  []
=end

CONCURRENT_ID = '20210226222727'


FOLDER = '/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/data/concours_distant'


PATH = File.join(FOLDER,CONCURRENT_ID)

if File.exists?(PATH)
  puts "Oui, il existe"
else
  puts "NON, il n'existe pas"
end
