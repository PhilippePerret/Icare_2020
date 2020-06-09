# encoding: UTF-8
=begin
  Méthodes générales utiles pour les strings
=end

# Avant de passer un string à ERB.new, il est bon de le passer par ici
def safe(str)
  str.force_encoding(Encoding::ASCII_8BIT).force_encoding(Encoding::UTF_8)
end #/ safe
