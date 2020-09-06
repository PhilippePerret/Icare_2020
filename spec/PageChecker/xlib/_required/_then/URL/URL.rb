# encoding: UTF-8
# frozen_string_literal: true
require 'nokogiri'

class Error404 < StandardError; def message; 404 end end

class URL
  attr_reader :iurl
  attr_reader :url
  # Contenu HTML de la page (obtenu par cUrl)
  attr_reader :html_content
  # L'instance Nokogiri::HTML de la page HTML
  attr_reader :noko

  # Instanciation d'une page, d'une URL.
  # +iurl+ Instance URLHref, avec le protocole, complète donc
  # +url+ est l'url complète, avec protocole
  # +options+ Pour définir certaines otpions, par la configuration par exemple
  def initialize(iurl, options = nil)
    @iurl = iurl
    @url = iurl.href
  end #/ initialize

  # = main =
  #
  # Méthode principale qui checke la page, c'est-à-dire :
  #   - qui vérifie qu'elle existe
  #   - qui vérifie qu'elle est conforme
  #   - qui vérifie que ses liens sont bons
  #
  # +options+
  #   :deep     Si false, on ne check pas les liens (pour une page externe
  #             par exemple.)
  #
  def check(options = nil)
    # TODO il faudra voir dans les pages_data.yaml s'il ne faut pas faire
    # quelque chose pour cette page.

    # puts "@check de #{url}"

    # Traitement spécial pour les fichier PDF
    # Pas pour le moment, car si le fichier n'existe pas, c'est quand même
    # une page HTML qui est présentée.
    if url.end_with?('.pdf')
    end

    @html_content = `cUrl -s #{url}`
    # -s    Pour ne pas avoir l'entête de progression, mais seulement le
    #       contenu de la page en retour

    # Débug : pour voir le contenu de la page
    # puts RC*3 + html_content


    # Première erreur possible : la page est introuvable
    raise(Error404) if page_404?

    # Sinon, on passe le document par Nokogiri
    @noko = Nokogiri::HTML(html_content)

    raise(Error404) if page_unfound?

    # On doit checker la page
    # TODO

    # Si on ne doit pas faire une recherche en profondeur, on s'arrête là
    return if not options[:deep]

    # On ajoute tous les liens pour les checker, si nécessaire.
    # Note : les doublons sont traités dans la méthode PageChecker.add_url
    links.each do |link|
      # puts link.formated_link_output
      PageChecker.add_url(full_url(link['href']), self, link.text)
    end

  rescue Exception => e
    case e.message
    when 404
      puts "Page introuvable".rouge
      iurl.add_error(404)
    else
      erreur(e.message)
      erreur(e.backtrace.join(RC))
    end
  end #/ check

  def full_url(route)
    return nil if route.nil?
    if route.start_with?('http')
      route
    else
      File.join(PageChecker.base_url, route)
    end
  end #/ full_url

  # Base à ajouter à tous les liens qui ne commencent pas par "https?"
  def base_uri
    @base_uri ||= begin
      b = noko.css("base")
      if b.empty?
        b.first['href']
      else
        url.dup << (url.end_with?('/') ? '' : '/')
      end
    end
  end #/ base_uri

  # Liste de tous les liens <A> du document
  def links
    @links ||= begin
      @noko.css('a')
    end
  end #/ links


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

end #/URL

module Nokogiri
module XML
class Element
  # Juste pour obtenir une version affichable d'un lien <A>
  def formated_link_output
    "#{attribute('href').value.ljust(30)}#{text}"
  end #/ formated_output
end #/Element
end #/XML
end #/Nokogiri
