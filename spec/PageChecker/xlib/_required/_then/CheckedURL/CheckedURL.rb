# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class CheckedURL
  ----------------
  Classe d'un lien checké. Un lien EST une URL ET une page, c'est la même
  chose. Quand un lien est trouvé dans une page (avec ou sans ancre, avec ou
  sans query-string) il est transformé en CheckedURL pour pouvoir être testé
  (sauf si des conditions l'excluent du check)
=end
require 'nokogiri'

class CheckedURL

  # Le checker de page {PageChecker} de l'url
  attr_reader :pagechecker

  # Lien complet, avec ancre et query-string if any
  attr_reader :full_url
  # Lien simple, sans ancre et sans query-string (c'est une méthode qui
  # le calcule)
  # attr_reader :url

  # Liste des erreurs rencontrées avec le lien
  attr_reader :errors

  # Liste des référents, c'est-à-dire des pages (instances CheckedURL) qui
  # contiennent ce lien checké
  attr_reader :referrers

  # Contenu HTML de la page (obtenu par cUrl)
  attr_reader :html_content

  # L'instance Nokogiri::HTML de la page HTML
  attr_reader :noko

  # Instanciation du lien, à l'aide de :
  # +pagechecker+ {PageChecker} L'instance actuelle (dans un contexte donné)
  # +full_url+    {String} Le lien complet tel qu'il est relevé
  def initialize pagechecker, full_url, data = nil
    @pagechecker  = pagechecker
    @full_url     = full_url
    @data         = data
  end #/ initialize

  # ---------------------------------------------------------------------
  #
  #   ÉTATS Methods
  #
  # ---------------------------------------------------------------------

  # Retourne TRUE si la page de l'url n'existe pas.
  # Soit elle retourne une erreur 404, soit elle contient l'élément
  # défini dans config.yaml qui indique comment reconnaitre une page
  # introuvable.
  def page_404?
    begin
      html_content.match?('<title>404 Not Found</title>')
    rescue Exception => e
      if e.message == 'invalid byte sequence in UTF-8'
        html_content.forceUTF8.match?('<title>404 Not Found</title>')
      else
        raise e
      end
    end
  end #/ check_content

  def page_unfound?
    if CONFIG[:unfound_if][:css]
      # puts noko.css(CONFIG[:unfound_if][:css]).inspect
      return true unless noko.css(CONFIG[:unfound_if][:css]).empty?
    end
    return false
  end #/ page_unfound?

  def deep_search_in_context?
    @deep_search_in_context ||= pagechecker.current_context.deep?(self) ? :true : :false
    @deep_search_in_context == :true
  end #/ deep_search_in_context?

  # ---------------------------------------------------------------------
  #
  #   CHECK Methods (méthodes de check)
  #
  # ---------------------------------------------------------------------


  # = main =
  #
  # Méthode principale qui checke la page, c'est-à-dire :
  #   - qui vérifie qu'elle existe
  #   - qui vérifie qu'elle est conforme
  #   - qui vérifie que ses liens sont bons (sauf si no-deep)
  #
  # +options+
  #
  def check(options = nil)

    write_check_header

    # TODO il faudra voir dans les pages_data.yaml s'il ne faut pas faire
    # quelque chose pour cette page.

    # Traitement spécial pour les fichier PDF
    # Pas pour le moment, car si le fichier n'existe pas, c'est quand même
    # une page HTML qui est présentée.
    if url.end_with?('.pdf')
    end

    # Note : les cookies sont là, notamment pour maintenir les sessions
    # quand il y a identification (cf. les contextes)
    @html_content = `cUrl -s --cookie cookies.txt --cookie-jar cookies.txt #{qs_url}`

    # -s    Pour ne pas avoir l'entête de progression, mais seulement le
    #       contenu de la page en retour

    # Débug : pour voir le contenu de la page
    # puts RC*3 + html_content


    # Première erreur possible : la page est introuvable
    raise(Error404) if page_404?

    # Sinon, on passe le document par Nokogiri
    @noko = Nokogiri::HTML(html_content)

    raise(Error404) if page_unfound?

    # On doit checker la page si des choses sont définies pour elle
    # TODO

    # Si on ne doit pas faire une recherche en profondeur, on s'arrête là
    return if CLI.option?(:not_deep) || not(pagechecker.in_domain?(url)) || not(deep_search_in_context?)

    # On ajoute tous les liens pour les checker, si nécessaire.
    # Note : les doublons sont traités dans la méthode PageChecker.add_url
    links.each do |link|
      # puts link.formated_link_output
      PageChecker.add_url(fill_url(link['href']), self, link.text)
    end

  rescue Exception => e
    case e.message
    when 404
      puts "Page introuvable".rouge
      add_error(404)
    else
      erreur(e.message)
      erreur(e.backtrace.join(RC))
    end
  end #/ check


  # ---------------------------------------------------------------------
  #
  #   ADD Methods (méthodes d'ajout)
  #
  # ---------------------------------------------------------------------

  # Ajout d'une erreur
  def add_error(str)
    @errors ||= []
    @errors << str
  end #/ error=

  # Ajout d'un référent
  # Rappel : un référent est une instance CheckedURL aussi
  def add_referrer(referrer)
    @referrers ||= []
    @referrers << referrer
  end #/ add_referrer

  # ---------------------------------------------------------------------
  #
  #   DISPLAY Methods (méthodes d'affichage)
  #
  # ---------------------------------------------------------------------

  # Écriture de la ou les lignes qui inaugure le check de cet URL
  def write_check_header
    puts "*** CHECK #{full_url} (reste #{pagechecker.urls_list.count})".bleu
    if CLI.option?(:referrer)
      puts "     From: #{referrers.first}".bleu
    end
    if not deep_search_in_context?
      puts "   Not Deep Search in context #{pagechecker.current_context.titre}".jaune
    end
  end #/ write_check_header

  # Mise en forme des référants
  def formated_referrers(prefix)
    @formated_referrers ||= begin
      referrers.collect do |ref|
        "#{prefix}#{ref.url}"
      end.join(RC)
    end
  end #/ formated_referrers

  # ---------------------------------------------------------------------
  #
  #   DATA Methods
  #
  # ---------------------------------------------------------------------

  # Méthode "remplissant" la route +route+. Par exemple, elle reçoit
  # 'user/login' et elle retourne "http://www.atelier-icare/user/login"
  # Si c'est déjà une URL complète, on la renvoie telle quelle
  def fill_url(route)
    return nil if route.nil?
    if route.start_with?('http')
      route
    else
      File.join(pagechecker.base_url, route)
    end
  end #/ fill_url

  # Liste de tous les liens <A> du document. Ce sont des nœud Nokogiri
  # donc des instances Nokogiri::XML::Element
  # Rappel : Nokogiri et XML sont des modules
  def links
    @links ||= @noko.css('a')
  end #/ links

  # URL avec le query string
  def qs_url
    @qs_url ||= full_url.split('#').first
  end #/ qs_url

  def url
    @url ||= qs_url.split('?').first
  end #/ url
  alias :href :url

end #/CheckedURL
