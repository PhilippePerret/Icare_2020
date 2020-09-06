# encoding: UTF-8
# frozen_string_literal: true
class Error200 < StandardError; def message; 200 end end
class Error404 < StandardError; def message; 404 end end

class URL
  attr_reader :url
  # Contenu HTML de la page (obtenu par cUrl)
  attr_reader :html_content

  # Instanciation d'une page, d'une URL.
  # +url+ est l'url complète, avec protocole
  # +options+ Pour définir certaines otpions, par la configuration par exemple
  def initialize(url, options = nil)
    @url = url
  end #/ initialize

  # = main =
  #
  # Méthode principale qui checke la page, c'est-à-dire :
  #   - qui vérifie qu'elle existe
  #   - qui vérifie qu'elle est conforme
  #   - qui vérifie que ses liens sont bons
  def check
    # TODO il faudra voir dans les pages_data.yaml s'il ne faut pas faire
    # quelque chose pour cette page.
    @html_content = `cUrl -s #{url}`
    # -s    Pour ne pas avoir l'entête de progression, mais seulement le
    #       contenu de la page en retour

    # Débug : pour voir le contenu de la page
    # puts RC*3 + html_content

    # Première erreur possible : la page est introuvable
    raise(Error404) if page_404?

  rescue Exception => e
    puts "e.message: #{e.message.inspect}"
    case e.message
    when 404
      puts "La page est introuvable".rouge
    end
  end #/ check

  def page_404?
    html_content.match?('<title>404 Not Found</title>')
  end #/ check_content

end #/URL
