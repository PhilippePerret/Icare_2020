# encoding: UTF-8
# frozen_string_literal: true
class PageChecker
class << self
  attr_reader :urls_list, :urls
  attr_accessor :current_context

  # = main =
  #
  # Méthode principale appelée pour checker l'url voulue
  def check_url
    if PAGES_DATA[:contexts]
      PAGES_DATA[:contexts].each do |dcontext|
        context = Context.new(self, dcontext)
        self.current_context = context
        puts "=== CONTEXTE : #{context.titre} ==="
        remove_cookie_file
        context.initiate
        traite_url
      end
    else
      # Sans contexte
      self.current_context = Context.new(self, {})
      traite_url
    end
    remove_cookie_file
  end #/ check_url

  def traite_url
    @urls = nil
    @urls_list = nil
    add_url(base_url, '--base--')
    check_all_urls
    display_report
  end #/ traite_url

  def remove_cookie_file
    File.delete('./cookies.txt') if File.exists?('./cookies.txt')
  end #/ remove_cookie_file


  def check_all_urls
    itimes = 0
    puts RC*2 + "=== DÉBUT ===".bleu
    deep = not(CLI.option?(:not_deep))
    write_referrer = CLI.option?(:referrer)
    itimes = 0
    while iurl = urls_list.pop
      puts "*** CHECK #{iurl.href} (reste #{urls_list.count})".bleu
      if write_referrer
        puts "     From: #{iurl.referrers.first}"
      end
      deep_search_in_context = self.current_context.deep?(iurl)
      if not deep_search_in_context
        puts "   Not Deep Search in context #{self.current_context.titre}".jaune
      end
      URL.new(iurl).check( deep: deep && in_domain?(iurl.href) && deep_search_in_context )
      itimes += 1
      # break if itimes > 10
    end
    puts RC*2 + "=== FIN (#{itimes} pages contrôlées) ===".bleu
  end #/ check_all_urls

  def display_report
    puts "#{RC*3}==== RAPPORT PageChecker ===="
    puts RC*2
    puts "Nombre de liens checkés : #{urls.count}"
    nombre_erreurs = 0
    erreurs = []
    urls.each do |hr, iurl|
      if iurl.errors
        nombre_erreurs += 1
        erreurs << "  ⛑  #{iurl.href}#{RC}#{iurl.formated_referrers("    ↲ ")}"
      end
    end
    if nombre_erreurs > 0
      # S'il y a des erreurs, on les affiche en mettant le détail
      puts "Nombre d'erreurs de liens : #{nombre_erreurs}"
      puts "Liens erronnés et pages d'appel".rouge
      puts "-------------------------------".rouge
      puts erreurs.join(RC).rouge
    else
      puts "Aucune erreur de lien !".vert
    end
  end #/ display_report

  # Ajoute l'URL +url+ mais seulement si elle n'existe pas
  # et si elle se trouve à la racine checkée
  # On retire les #abc (ancres)
  # Quand on ajoute une url, il faut aussi mémoriser son referrer pour
  # savoir où il faudra faire des corrections
  def add_url(url, referrer, title =  nil)
    url || return # balise <A> sans href
    url = url.split('#').first
    @urls ||= {}
    @urls_list ||= []
    if @urls.key?(url)
      #  Si cet URL existe déjà, on ajoute simplement le referrer
      @urls[url].add_referrer(referrer)
      return
    end
    # puts "-> ajout de #{url.inspect}"
    iurl = URLHref.new(url, title)
    # S'il faut exclure l'URL dans le contexte donné
    # On doit le mettre ici car la méthode exclude? essaye avec l'url telle
    # quelle est aussi avec l'URL sans query-string ni ancre
    if self.current_context.exclude?(iurl)
      puts "<-> EXCLUDED URL: #{url}".jaune
      return
    end
    iurl.add_referrer(referrer)
    @urls.merge!(url => iurl)
    @urls_list << iurl
  end #/ add_url

  # Retourne true si +url+ est dans le domaine checké (pour savoir s'il faut
  # faire une recherche en profondeur)
  def in_domain?(url)
    url.start_with?(base_url)
  end #/ in_domain?

  def base_url
    @base_url ||= CONFIG[:url][CLI.option?(:online) ? :online : :offline]
  end #/ base_url
  alias :base :base_url

end # /<< self
end #/PageChecker

URLHref = Struct.new(:href, :title) do
  attr_reader :errors, :referrers

  def pure_url
    @pure_url ||= href.split('#').first.split('?').first
  end #/ pure_url

  def add_error(str)
    @errors ||= []
    @errors << str
  end #/ error=
  def add_referrer(referrer)
    @referrers ||= []
    @referrers << referrer
  end #/ add_referrer

  # Mise en forme des référants
  def formated_referrers(prefix)
    @formated_referrers ||= begin
      referrers.collect do |ref|
        "#{prefix}#{ref.url}"
      end.join(RC)
    end
  end #/ formated_referrers

end
