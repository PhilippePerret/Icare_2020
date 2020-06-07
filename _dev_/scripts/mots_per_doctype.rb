# encoding: UTF-8
=begin
  Pour faire des essais ruby
=end
require 'json'

data_docs = [
[181, 15190, 'odt'],
[787,23054, 'odt'],
[401, 21500, 'odt'],
[204, 15000, 'odt'],
[381, 20250, 'odt'],
[10845, 61650, 'odt'],

[285, 2535, 'rtf'],
[800, 6000, 'rtf'],
[434, 4800, 'rtf'],

[2178, 91650, 'doc'],
[169, 25600, 'doc'],
[410, 16900, 'doc'],

[2178, 49850, 'docx'],
[4694, 40640, 'docx'],
[1055, 9837, 'docx'],
[2047, 13215, 'docx'],
[22600, 113800, 'docx'],

]

MOYENNES = {

}

data_docs.each do |tierce|
  nombre_mots, size, extension = tierce
  ratio = (nombre_mots.to_f / size).round(3)
  if MOYENNES.key?(extension)
    MOYENNES[extension] = (((MOYENNES[extension] + ratio).to_f) / 2).round(3)
  else
    MOYENNES.merge!(extension => ratio)
  end
  puts "extension : #{extension} : #{ratio} - #{MOYENNES[extension]}"
end

any = 0.0
MOYENNES.each do |k,v|
  any += v
end
any = (any.to_f / MOYENNES.count).round(3)
MOYENNES.merge!('any' => any)

puts "\n\nÀ COPIER DANS LE FICHIER :\n\n"
puts "RATIO_MOTS_PER_DOCTYPE = {"
MOYENNES.each do |k,v|
  if k == 'any'
    puts "  '#{k}' => #{v}"
  else
    puts "  '.#{k}' => #{v},"
  end
end
puts "}"
