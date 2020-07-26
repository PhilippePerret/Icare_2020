# encoding: UTF-8
=begin

  Class VPage
  -----------
  Instance de validation de la page

=end
class VPage < ContainerClass
# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------
SUBJECT_LINE      = '<span class="route">Route</span>'
VALIDATION_LINE   = '<span class="route">%{route}</span>'.freeze
SPAN_CHECKBOX_TAG = '<span class="col-cb"><input type="checkbox" name="cpage_%{id}_spec_%{bit}"%{checked} /></span>'
PICTO_BIT         = '<span class="col-cb"><img src="img/Emojis/%{relpath}" class="picto-bit" /></span>'.freeze
DATA_BITS_VALIDATOR = {
  0   => {name:'Corrigé', picto:'humain/marion'},
  1   => {name:'Finalisé', picto:'humain/phil'},
  2   => {name:'Sur Mac', picto:'machine/mac'},
  3   => {name:'Sur windows', picto:'machine/windows'},
  4   => {name:'Sur tablette', picto:'machine/tablette'},
  5   => {name:'Sur iPhones',  picto:'machine/iphone'},
  6   => {name:'Sur Androïde',  picto:'machine/androide'},
  31  => {name:'Prioritaire',   picto:'signes/exclamation'},
}
ORDRE_BITS = [0,1,2,3,4,5,6,31]
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table ||= 'validations_pages'
  end #/ table
  def subject_line
    ORDRE_BITS.each do |bit|
      SUBJECT_LINE << PICTO_BIT % {relpath:DATA_BITS_VALIDATOR[bit][:picto]}
    end
    SUBJECT_LINE.freeze
  end #/ subject_line
end # /<< self


# Sortie de la ligne de validation
def validation_line
  dataline = {route: route}
  line = (VALIDATION_LINE % dataline)
  ORDRE_BITS.each do |bit|
    line << (SPAN_CHECKBOX_TAG % {id:id, bit:bit, checked:checked_for(bit)})
  end
end #/ validation_line

def checked_for(bit)
  checked?(bit) ? CHECKED : EMPTY_STRING
end #/ checked_for
def checked?(bit)
  spec(bit) == 1
end #/ checked?
# ---------------------------------------------------------------------
#   Spécifications
#   Concerne la donnée SPECS qui est un string de 32 caractères qui
#   définit l'état de chaque chose
#   Bit       Quand 1
#   -------------------------------
#     0   Corrigée par Marion
#     1   Corrections de Marion effectuée et validée par moi
#     2   Affichage correct sur mac
#     3   Affichage correct sur Windows
#     4   Affichage correct sur une tablette
#     5   Affichage correct sur iPhones
#     6   Affichage correct sur Androïde
#
#     31  Prioritaire
# ---------------------------------------------------------------------
def corrected_by_marion
  spec(0)
end #/ corrected_by_marion?
def phil_validation
  spec(1)
end #/ phil_validation?
def aspect_mac
  spec(2)
end #/ aspect_mac?
def aspect_pc
  spec(3)
end #/ aspect_pc?
def aspect_tablette
  spec(4)
end #/ aspect_tablette
def aspect_iphones
  spec(5)
end #/ aspect_iphones
def aspect_androides
  spec(6)
end #/ aspect_androide

def priority
  spec(31)
end #/ priority

def spec(bit, value = nil, save = true)
  if value.nil? # on veut obtenir la valeurs
    (specs||'0'*32)[bit].to_i
  else
    # On veut définir la valeur
    data[:specs] ||= '0'*32
    data[:specs][bit] = value.to_s
    save(:specs)
  end
end #/ spec

end #/VPage
