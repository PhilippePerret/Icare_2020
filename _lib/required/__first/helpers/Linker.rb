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

      :query_string permet d'ajouter des données query string (pour le
      moment elles doivent être formatées)

  CHANGEMENT DU TEXTE
  -------------------
    On change très facilement le titre du lien (le texte qui apparait) avec
    la méthode :with :
      lien.with("C'est mon nouveau texte")
      # ou
      lien.with(text: "nouveau", ...)
=end
require_relative './Tag'
require './_lib/required/_classes/App'

class Linker
  attr_reader :data, :default_text, :route, :base_url
  def initialize(withdata)
    @default_text = withdata[:text]
    @route        = withdata[:route]
    @base_url     = withdata[:base_url] # p.e. "https://www.scenariopole.fr"
    @data = withdata
  end #/ initialize

  def to_str
    @default_link ||= begin
      reset
      Tag.link(filldata.merge!(route: real_route, text: default_text || route))
    end
  end #/ to_str
  alias :to_s :to_str

  # Retourner un lien avec les données +wdata+ qui peuvent redéfinir presque
  # tous les aspects du lien original, jusqu'à la route (quand le linker, par
  # exemple, c'est un lien "générique" comme un lien vers la collection
  # narration).
  def with(wdata)
    reset
    wdata = {text: wdata} if wdata.is_a?(String)
    @data = data.merge(wdata)
    has_absolute_path if data.delete(:absolute) || data.delete(:full)
    has_distant_path if data.delete(:online) || data.delete(:distant)
    @qs = data[:query_string]
    data.merge!(text: default_text) unless data.key?(:text)
    data.merge!(text: real_route(wdata[:route])) if data[:text].nil?
    Tag.link(filldata.merge!(route: real_route(wdata[:route])))
  end #/ with

private

  def filldata
    d = data.dup
    d.merge!(class: nil)  unless d.key?(:class)
    d.merge!(target: nil) unless d.key?(:target)
    d.delete(:full) if d.key?(:distant) || d.key?(:absolute)
    return d
  end #/ filldata

  def real_route(def_route = nil)
    def_route ||= route
    real_base = base
    if not real_base.nil?
      real_base = "#{real_base}/" if not(def_route.nil?) && not(real_base.end_with?("/"))
    end
    "#{real_base}#{def_route}#{query_string}"
  end #/ real_route

  def base
    base_url || (absolute_path? ? "#{url}/" : nil)
  end #/ base

  def url
    distant_path? ? App::FULL_URL_ONLINE : App.url
  end #/ url

  def query_string
    if @qs then "?#{@qs}" end
  end #/ query_string

  # Avant chaque lien il faut resetter pour ne pas prendre le réglage d'avant
  def reset
    @real_route         = nil
    @qs                 = nil
    @has_absolute_path  = nil
    @has_distant_path   = nil
  end #/ reset

  def has_absolute_path
    @has_absolute_path = :true
  end #/ has_absolute_path
  def absolute_path?
    @has_absolute_path == :true
  end #/ absolute_path?

  def has_distant_path
    @has_distant_path = :true
    @has_absolute_path = :true
  end #/ has_distant_path
  def distant_path?
    @has_distant_path == :true
  end #/ distant_path?
end #/Linker
