# encoding: UTF-8
=begin
  Méthodes générales utiles pour les strings
=end

# Pour remplace URI.encode qui est obsolète
def uri_encode(str)
  URI.encode_www_form_component(str)
end #/ uri_encode

# Avant de passer un string à ERB.new, il est bon de le passer par ici
def safe(str)
  # log("transformation de #{str.inspect}")
  return nil if str.nil?
  str.force_encoding(Encoding::ASCII_8BIT).force_encoding(Encoding::UTF_8)
end #/ safe

# Évalue le code +code+ qui est soit du ERB soit du MARDOWN en le bindant
# à +owner+ s'il est défini.
# +options+
#     :formate    {Boolean} Si false, on n'applique pas le formatage spécial
def deserb_or_markdown code, owner = nil, options = nil
  code = safe(code)
  return '' if code.nil_if_empty.nil?
  str = if code.include?('<%')
          Deserb.deserb(code, owner)
        else
          AIKramdown.kramdown(code, owner)
        end
  return str if options && options[:formate] === false
  str&.special_formating
end #/ deserb_or_markdown
