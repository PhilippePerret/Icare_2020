# encoding: UTF-8
=begin
  Constantes utiles
=end

# Le style pour un bouton dans un mail
# @usage Tag.lien(text:..., full:true, style: STYLE_BUTTON_MAIL)
STYLE_BUTTON_MAIL = "text-decoration:none;padding:0.4em 1.1em 0.3em;border:1px solid;border-radius:4px;background-color:steelblue;color:white;"

# Table de remplacement pour les caractères spéciaux dans les
# sujets de mail
# Cf. http://www.fileformat.info/info/unicode/char/00f4/index.htm
#     http://www.fileformat.info/info/unicode/category/Po/list.htm
HCARH_TO_MAILCHAR = {
  '[' => '5b',
  ']' => '5d',
  '|' => '6c',
}
HCARH_TO_MAILCHAR_WITH_C3 = {
  'ç' => 'A7', # -> =C3=A7
  'Ç' => '87',
  'é' => 'A9',
  'É' => '89',
  'è' => 'A8',
  'ê' => 'AA',
  'ë' => 'AB',
  'Ê' => '8A',
  'à' => 'A0',
  'â' => 'A2',
  'æ' => 'A6',
  'Â' => '82',
  'Ô' => '94',
  'ô' => 'F4',
  'ö' => 'B6',
  'Œ' => ['C5','92'],
  'œ' => ['C5','93'],
  'ù' => 'B9',
  'û' => 'BB',
  'ü' => 'BC',
  'Ù' => '99',
  'Û' => '9B',
  'î' => 'AE',
  'ï' => 'AF',
  '…' => ['E2','80','A6'],
}
def define_table_subject_chars
  h = {}
  HCARH_TO_MAILCHAR.each do |bc, gc|
    h.merge!(bc => "=#{gc}")
  end
  HCARH_TO_MAILCHAR_WITH_C3.each do |bc, gc|
    if gc.is_a?(String)
      h.merge!(bc => "=C3=#{gc}")
    else
      h.merge!(bc => gc.collect{|c|"=#{c}"}.join(EMPTY_STRING))
    end
  end
  return h
end #/ define_table_subject_chars
TABLE_SUBJECT_CHARS = define_table_subject_chars
# allkeys = (HCARH_TO_MAILCHAR.keys+HCARH_TO_MAILCHAR_WITH_C3.keys).join(EMPTY_STRING)
# REG_SUBJECT_CHARS = /[#{allkeys}]/

# Récupéré du javascript :
  #   var strReg = ""
  #   for ( var letter in hreplace ){
  #     var co = hreplace[letter]
  #     strReg += letter
  #     if ( typeof co === 'string' ) {
  #       co = `=C3=${co}`
  #     } else {
  #       co = co.map( oc => `=${oc}`).join('')
  #     }
  #     hreplace[letter] = co
  #   }
  #   this.regHashReplacement = hreplace
  #   this.regSpeciaux = new RegExp(`([${strReg}])`,'g')
  # }
