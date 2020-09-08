# encoding: UTF-8
# frozen_string_literal: true
class PageChecker
class << self
  attr_reader :urls_list, :urls
  attr_accessor :current_context

  # = main =
  #
  # Méthode principale appelée pour checker l'url voulue
  def check_website
    puts "=== Check du site ".bleu + base.vert + " ===".bleu
    if PAGES_DATA[:contexts] && CLI.option?(:context)
      if PAGES_DATA[:contexts].key?(CLI.option(:context).to_sym)
        traite_context(Context.new(self, PAGES_DATA[:contexts][CLI.option(:context).to_sym]))
      else
        erreur("Je ne connais pas le context :#{CLI.option(:context)} (les contextes sont : #{PAGES_DATA[:contexts].keys.join(', ')}).")
      end
    elsif PAGES_DATA[:contexts]
      # On traite dans tous les contextes
      PAGES_DATA[:contexts].each do |idcontext, dcontext|
        traite_context(Context.new(self, dcontext)) || break
      end
    else
      # Sans contexte
      traite_context(Context.new(self, {}))
    end
  end #/ check_website

  # Pour traiter le site dans un certain contexte (par exemple celui d'un
  # utilisateur identifié ou d'un administrateur)
  def traite_context(context)
    PageChecker.contexts << context
    self.current_context = context
    if context.titre
      puts "=== Contexte : ".bleu + context.titre.vert + "#{} ===".bleu
    end
    remove_cookie_file
    context.initiate
    ok_suite = traite_urls_in_context
    remove_cookie_file

    return ok_suite
  end #/ traite_context

  def traite_urls_in_context
    @urls       = {}
    @urls_list  = []
    add_url(base_url, nil, '--base--')
    ok_suite = check_all_urls
    display_report

    return ok_suite
  end #/ traite_urls_in_context

  def check_all_urls
    itimes = 0
    puts RC*2 + "=== CHECK START ===".bleu
    deep = not(CLI.option?(:not_deep))
    itimes = 0
    while iurl = urls_list.pop
      iurl.check
      itimes += 1
      if CLI.option?(:max) && itimes >= CLI.option(:max)
        return false # pour arrêter
      end
    end
    puts RC*2 + "=== FIN (#{itimes} pages contrôlées) ===".bleu

    return true
  end #/ check_all_urls

  def display_report
    tableau = ["#{RC*3}==== RAPPORT Contexte #{self.current_context.titre} ===="]
    tableau << ["="]
    tableau << "= Nombre de liens checkés : #{urls.count}"
    nombre_erreurs = 0
    erreurs = []
    urls.each do |hr, iurl|
      if iurl.errors
        nombre_erreurs += 1
        erreurs << "  ⛑  #{iurl.href}#{RC}= #{iurl.formated_referrers("=     ↲ ")}"
      end
    end
    if nombre_erreurs > 0
      # S'il y a des erreurs, on les affiche en mettant le détail
      tableau << "= Nombre d'erreurs de liens : #{nombre_erreurs}"
      tableau << "= Liens erronnés et pages d'appel".rouge
      tableau << "=-------------------------------".rouge
      tableau << "= #{erreurs.join(RC+'= ')}".rouge
    else
      tableau << "= Aucune erreur de lien !".vert
    end

    tableau = tableau.join(RC)
    # On l'écrit à la fin de ce check
    puts tableau
    # On l'enregistre dans le contexte pour l'affichage final
    self.current_context.tableau_resultats = tableau
  end #/ display_report

  # Ajoute l'URL +url+ mais seulement si elle n'existe pas
  # et si elle se trouve à la racine checkée
  # On retire les #abc (ancres)
  # Quand on ajoute une url, il faut aussi mémoriser son referrer pour
  # savoir où il faudra faire des corrections
  def add_url(url, referrer, title =  nil)
    url || begin
      # QUESTION Faut-il mettre en erreur les liens avec href null ou
      # faut-il vérifier avant s'il s'agit d'une ancre.
      return # balise <A> sans href
    end
    STDOUT.write "    -> add_url(#{url.inspect})" if CLI.option?(:verbose)
    url = url.split('#').first
    if @urls.key?(url)
      #  Si cet URL existe déjà, on ajoute simplement le referrer
      @urls[url].add_referrer(referrer) unless referrer.nil?
      puts " NO".rouge if CLI.option?(:verbose)
      return
    end
    # puts "-> ajout de #{url.inspect}"
    iurl = CheckedURL.new(self, url, {title: title})
    # S'il faut exclure l'URL dans le contexte donné
    # On doit le mettre ici car la méthode exclude? essaye avec l'url telle
    # quelle est aussi avec l'URL sans query-string ni ancre
    if self.current_context.exclude?(iurl)
      puts " EXCLUDED".jaune
      return
    else
      puts " OUI".vert if CLI.option?(:verbose)
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

private

  # ---------------------------------------------------------------------
  #
  #   Fichier cookies
  #
  # ---------------------------------------------------------------------

  # Détruit le fichier cookie
  # Note : que ce soit en local ou en distant, le fichier est toujours
  # enregistré localement puisque c'est la commande CURL qui l'utilise.
  def remove_cookie_file
    remove_cookie_file_local
  end #/ remove_cookie_file

  def remove_cookie_file_local
    File.delete('./cookies.txt') if File.exists?('./cookies.txt')
  end #/ remove_cookie_file_local

  # Obsolète (le fichier est toujours local)
  def remove_cookie_file_distant
    PageChecker.ssh_exec('rm ./www/cookie.txt')
  end #/ remove_cookie_file_distant

end # /<< self
end #/PageChecker
