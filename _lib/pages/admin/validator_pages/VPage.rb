# encoding: UTF-8
=begin

  Class VPage
  -----------
  Instance de validation de la page

=end
class VPage < ContainerClass
class << self
  def table
    @table ||= 'validations_pages'
  end #/ table
end # /<< self

SUBJECT_LINE    = '<span class="route">Route</span>'.freeze
VALIDATION_LINE = '<span class="route">%{route}</span>'.freeze

# Sortie de la ligne de validation
def validation_line
  VALIDATION_LINE % {
    route: route
  }
end #/ validation_line
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
