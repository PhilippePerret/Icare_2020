# encoding: UTF-8
# frozen_string_literal: true
require 'json'
SCORE_PATH = "/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/data/concours/20161121150532/20161121150532-2021/evaluation-1.json"
File.exists?(SCORE_PATH) || raise("Le fichier score n'existe pas ou plus.")
DATA_SCORE = JSON.parse(File.read(SCORE_PATH))
NOMBRE_QUESTIONS = File.read("/Users/philippeperret/Sites/AlwaysData/Icare_2020/_lib/data/concours/NOMBRE_QUESTIONS").to_i

puts DATA_SCORE
puts "Nombre de clés (de questions) : #{DATA_SCORE.keys.count}"
nombre_undone = 0
DATA_SCORE.each do |k, v|
  if v == '-'
    nombre_undone += 1
  end
end
puts "Nombre réponses manquantes : #{nombre_undone}"
puts "Nombre total de questions : #{NOMBRE_QUESTIONS}"
puts "Nombre réponses : #{NOMBRE_QUESTIONS - nombre_undone}"
