# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class MainLink
  --------------
  Pour gérer les liens courants avec des simples `MainLink[:key].simple`
=end

class MainLink
DATA_KEY = {
  signup:     {route:'user/signup',  text:'s’inscrire', picto:''},
  login:      {route:'user/login',   text:'s’identifier'},
  logout:     {route:'user/logout',  text:'se déconnecter'},
  aide:       {route:'aide/home',    text:'aide',     picto:'objets/gyrophare'},
  bureau:     {route:'bureau/home',  text:'bureau',   picto:'objets/bureau'},
  frigo:      {route:'bureau/frigo', text:'Porte de frigo%{pastille}',  picto:'objets/thermometre'},
  contact:    {route:'contact/mail', text:'contact', picto:'objets/lettre-mail'},
  plan:       {route:'plan', text:'plan', picto:'objets/boussole'},
  reussites:  {route:'overview/reussites', text:'belles réussites', picto:'objets/paquet-cadeau'},
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
  ftext = ftext % {pastille:params[:pastille]} if params.key?(:pastille)
  ftext = emoji+ISPACE+ftext if params[:picto]
  build_tag(text: ftext, class:params[:class])
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
  @id ||= data[:id] || "btn-#{key}"
end #/ id
def css
  @css
end #/ css
def data
  @data ||= self.class::DATA_KEY[key]
end #/ data
end #/MainLink
