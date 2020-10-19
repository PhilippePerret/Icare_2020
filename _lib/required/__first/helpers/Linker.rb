# encoding: UTF-8
# frozen_string_literal: true
=begin
  Pour faciliter la gestion des liens
  On crée une instance Linker et on peut l'utiliser ensuite de différentes
  façons.

  INSTANCIATION
  -------------
    On instancie un linker avec :
      text:   son texte par défaut
      route:  sa route
    Par exemple lien = Linker.new(text:"Concours", route:"concours/home")

  UTILISATION
  -----------
    On peut ensuite l'utilisation tel quel :
      - dans un fichier ERB
        <%= lien %>
      - dans un mail
        <%= lien.with(absolute:true) %>
        # le absolute:true permet de mettre l'URL complète
        Un mail envoyé depuis l'ordinateur (en mode local et :force) :
        <%= lien.with(absolute:true, online:true) %>
        … pour que ce soit l'adresse distante qui soit utilisée
      - dans un code ruby
        #{lien}

  CHANGEMENT DU TEXTE
  -------------------
    On change très facilement le titre du lien (le texte qui apparait) avec
    la méthode :with :
      lien.with("C'est mon nouveau texte")
      # ou
      lien.with(text: "nouveau", ...)
=end
require_relative './Tag'

class Linker
  attr_reader :default_text, :route
  def initialize(withdata)
    @default_text = withdata[:text]
    @route        = withdata[:route]
  end #/ initialize
  def to_str
    default_template % {route: real_route, text: default_text || route}
  end #/ to_str
  def real_route
    finpath = "#{@path_absolu ? "#{url}/" : ""}#{route}"
    @path_absolu = nil
    finpath
  end #/ real_route
  alias :to_s :to_str

  def url
    @for_url_online ? App::FULL_URL_ONLINE : App.url
  end #/ url

  def with(data)
    data = {text: data} if data.is_a?(String)
    @path_absolu    = true if data[:absolute]
    @for_url_online = true if data[:online]
    data.merge!(text: default_text) unless data[:text]
    default_template % data.merge!(route: real_route)
  end #/ with
  def absolute # pour utilisation avec .with(...) ensuite
    @path_absolu = true
    return self
  end #/ absolute
  def default_template
    @default_template ||= Tag.link(route: '%{route}', text: '%{text}')
  end #/ default_template
end #/Linker
