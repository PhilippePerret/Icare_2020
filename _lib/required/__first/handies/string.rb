# encoding: UTF-8
=begin
  Méthodes générales utiles pour les strings
=end

# Avant de passer un string à ERB.new, il est bon de le passer par ici
def safe(str)
  str.force_encoding(Encoding::ASCII_8BIT).force_encoding(Encoding::UTF_8)
end #/ safe

# Évalue le code +code+ qui est soit du ERB soit du MARDOWN en le bindant
# à +owner+ s'il est défini.
def deserb_or_markdown code, owner = nil
  code = safe(code)
  return '' if code.nil_if_empty.nil?
  if code.include?('<%')
    Deserb.deserb(code, owner)
  else
    AIKramdown.kramdown(code, owner)
  end
end #/ deserb_or_markdown
