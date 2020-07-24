# encoding: UTF-8
=begin
  Class MainLink
  --------------
  Pour gérer les liens courants avec des simples `MainLink[:key].simple`
=end

class MainLink
DATA_KEY = {
  signup:     {route:'user/signup'.freeze,  text:'s’inscrire'.freeze, picto:''},
  login:      {route:'user/login'.freeze,   text:'s’identifier'.freeze},
  logout:     {route:'user/logout'.freeze,  text:'se déconnecter'.freeze},
  aide:       {route:'aide/home'.freeze,    text:'aide'.freeze,     picto:'objets/gyrophare'.freeze},
  bureau:     {route:'bureau/home'.freeze,  text:'bureau'.freeze,   picto:'objets/bureau'.freeze},
  frigo:      {route:'bureau/frigo'.freeze, text:'porte de frigo',  picto:'objets/thermometre'.freeze},
  contact:    {route:'contact/mail'.freeze, text:'contact', picto:'objets/lettre-mail'.freeze},
  plan:       {route:'plan'.freeze, text:'plan', picto:'objets/boussole'.freeze},
  reussites:  {route:'overview/reussites'.freeze, text:'belles réussites', picto:'objets/paquet-cadeau'.freeze},
}
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
def [] key
  @main_links ||= {}
  @main_links[key] ||= new(key)
end #/[]
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :key
def initialize key
  @key = key
end #/ initialize

def build_tag(params = nil)
  params ||= {}
  params[:route]  ||= data[:route]
  params[:text]   ||= data[:text]
  params[:class]  ||= css
  params[:id]     ||= id
  return Tag.link(params)
end #/ tag

# ---------------------------------------------------------------------
#   Méthodes publiques
#   (MainLink[:key].<methode>[<options>])
# ---------------------------------------------------------------------

def simple(options = nil)
  build_tag # sans rien d'autre
end #/ simple

# +params+
#   :picto      {Boolean}   Si TRUE, on ajoute le picto (qui doit être un émoji)
#   :titleize   {Boolean}   Si TRUE, on met une capitale
#   :pastille   {String} Dans le texte (titre du lien), remplace %{non_vus} par
#               le texte fourni
def with(params)
  ftext = (params[:text]||self.data[:text]).dup
  ftext = ftext.capitalize if params[:titleize]
  ftext = ftext % {non_vus:params[:pastille]} if params.key?(:pastille)
  ftext = emoji+ISPACE+ftext if params[:picto]
  build_tag(text: ftext)
end #/ with

# ---------------------------------------------------------------------
#   Méthodes fonctionnelles
# ---------------------------------------------------------------------

def emoji
  @emoji ||= Emoji.get(data[:picto]).regular
end #/ emoji

# ---------------------------------------------------------------------
#   Méthodes de données
# ---------------------------------------------------------------------

def id
  @id ||= data[:id] || "btn-#{key}".freeze
end #/ id
def css
  @css
end #/ css
def data
  @data ||= self.class::DATA_KEY[key]
end #/ data
end #/MainLink
