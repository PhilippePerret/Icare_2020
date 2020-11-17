# encoding: UTF-8
# frozen_string_literal: true
=begin
  Matchers de page (Capybara::Session)
=end
RSpec::Matchers.define :have_no_erreur do
  match do |page|
    if page.has_css?('div.errors')
      @erreurs_messages = page.find('div.errors').text # TODO S'il y en a plusieurs (find_all ?)
      screenshot('erreur-page-with-errors')
      false
    else
      true
    end
  end
  description do
    "La page ne contient aucun message d'erreur."
  end
  failure_message do
    "La page ne devrait contenir aucune erreur. Elle contient : #{@erreurs_messages}"
  end
end
RSpec::Matchers.alias_matcher :have_aucune_erreur, :have_no_erreur


RSpec::Matchers.define :have_error do |err_msg|
  match do |page|
    err_msg || raise("Il faut fournir le message d'erreur à trouver !")
    err_msg = err_msg.gsub(/<br ?>/,"\n").strip_tags
    if page.has_css?('div.errors')
      # if page.has_css?('div.errors', text: /#{Regexp.escape(err_msg)}/)
      if page.has_css?('div.errors', text: err_msg.gsub(/ /,' '))
        return true
      else
        actua_msg = page.find('div.errors').text
        @ajout = "En revanche, le message “#{actua_msg}” a été trouvé."
        return false
      end
    else
      @ajout = "Elle ne contient aucun message d’erreur."
      return false
    end
  end
  failure_message do
    "La page devrait contenir le message d’erreur “#{err_msg}”. #{@ajout}"
  end
  description do
    "La page contient bien le message d’erreur “#{err_msg}”."
  end
end
RSpec::Matchers.alias_matcher :have_erreur, :have_error

RSpec::Matchers.define :have_message do |msg|
  match do |page|
    @errors = []
    msg || raise("Il faut fournir le message à trouver !")
    msg = msg.gsub(/<br ?>/,"\n").strip_tags
    selector =  if page.has_css?('section#messages div.notices')
                  'section#messages div.notices'
                elsif page.has_css?('section#flash div.message')
                  'section#flash div.message'
                else
                  nil
                end
    # A-t-on un message dans la page ?
    if selector.nil?
      @errors << "Aucun message n'est affiché dans la page."
    elsif not page.has_css?(selector, text: msg.gsub(/ /,' '))
      # Le message affiché
      actua_msg = page.all(selector).collect do |el|
        el.text
      end.join(' / ')
      @errors << "Le message #{msg.inspect} n'a pas été trouvé, en revanche la page affiche le message #{actua_msg.inspect}."
    end
    return @errors.empty?
  end
  failure_message do
    @errors.join(' ')
  end
  description do
    "La page contient bien le message  “#{msg}”."
  end
end

# Matcher pour vérifier que la notification décrite par +params+ existe
# bien dans la page.
RSpec::Matchers.define :have_notification do |params|
  match do |page|
    # On doit déjà se trouver dans la page des notifications
    if page.has_css?('h2.page-title', text:'Notifications')
      params = {id: params} if params.is_a?(Integer)
      if params.key?(:id)
        if params[:id].is_a?(Array)
          candidats = params[:id]
        else
          candidats = [params[:id]]
          params.merge!(count: 1)
        end
      elsif params.key?(:ids)
        candidats = params[:ids]
      else
        # L'ID du watcher n'est pas fourni, il faut le récupérer à l'aide
        # des paramètres.
        datasearch = {}
        [:user_id, :wtype, :objet_id].each do |prop|
          datasearch.merge!(prop => params[prop]) if params.key?(prop)
        end
        candidats = db_get_all('watchers', datasearch).select do |dwat|
          if params.key?(:after)
            next false if dwat[:created_at].to_i < params[:after]
          end
          if params.key?(:before)
            next false if dwat[:created_at].to_i > params[:before]
          end
          true
        end.collect { |dwat| dwat[:id] }
      end # /recherche de l'identifiant

      if candidats.count == 0
        @error = "Aucune notification trouvé dans la DB avec #{datasearch.inspect}…"
        return false
      end
      # À partir d'ici, candidats est une liste d'identifiants
      trouved = candidats.select do |wid|
        watchertype = case
        when params[:unread] then '.unread'
        when params[:major]  then '.major'
        else ''
        end
        selector = "div.watcher#watcher-#{wid}#{watchertype}"
        page.has_css?(selector)
      end

      if trouved.count == 0
        @error = "Aucune notification trouvée parmi #{candidats.join}."
        return false
      end

      # On doit définir le nombre de notifications attendues
      if params.key?(:only_one)
        params.merge!(count: 1)
      elsif !params.key?(:count)
        params.merge!(count: candidats.count) # on doit trouver tous les candid
      end

      if trouved.count != params[:count]
        s = params[:count] > 1 ? 's' : ''
        st = trouved.count > 1 ? 's' : ''
        @error = "#{params[:count]} notification#{s} attendue#{s}, #{trouved.count} trouvée#{st} dans la DB…"
        return false
      end
      if trouved.count == 0
        @error = params.inspect
      end
      $notifications_ids  = trouved
      $notification_id    = trouved.first
      return trouved.count > 0 # Résultat final
    else
      @error = "on ne se trouve pas sur la page des notifications…"
      false
    end
  end
  failure_message do
    "La page ne contient pas cette notification : #{@error}"
  end
  description do
    "La notification a été trouvée."
  end
end # /have_notification

RSpec::Matchers.alias_matcher :have_notifications, :have_notification

RSpec::Matchers.define :have_route do |expected_route, options|
  match do |page|
    if page.current_url == "about:blank"
      raise "Aucune page internet n'est chargée…"
    end
    parsed = URI.parse(page.current_url)
    # puts "URI.parse(page.current_url): #{parsed.inspect}"
    # puts "URI.parse(page.current_url).query: #{parsed.query.inspect}"
    # puts "parsed.methods: #{parsed.methods}"
    # puts "parsed.path: #{parsed.path.inspect}"
    @page_route = parsed.path.sub(/\/AlwaysData\/Icare_2020\//,'')
    ok = expected_route == @page_route
    if options
      if options.key?(:query)
        # TODO Plus tard, on pourra vraiment mettre dans une table clé=>valeur
        # et tester comme ça. Ici, si les arguments ne sont pas mis dans le
        # même ordre, le résultat est faux.
        ok = ok && parsed.query == options[:query]
        @page_route = "#{@page_route.inspect} avec le query-string #{parsed.query.inspect}"
      elsif options.key?(:not_query)
        @page_route = "#{@page_route.inspect} avec le query-string #{parsed.query.inspect}"
        ok = ok && parsed.query != options[:query]
      end
      # Par exemple un query-string ?
    end
    ok
  end
  description do
    "La page possède bien la route '#{expected_route}'"
  end
  failure_message do
    expects = []
    expects << "la route #{expected_route.inspect}"
    expects << "le query-string #{options[:query].inspect}" if options[:query]
    expects << "sans le query-string #{options[:not_query].inspect}" if options[:not_query]
    "La page devrait posséder #{expects.join(', ')}. Sa route est #{@page_route}"
  end
end

RSpec::Matchers.define :have_titre do |expected, options|
  match do |page|
    @errors = []
    if page.has_css?('h2.page-title')
      @actual = page.find('h2.page-title').text
      expected = Regexp.new(expected) if expected.is_a?(String)
      ok = @actual =~ expected
      ok || @errors << "le titre devrait être à peu près “#{expected.source}”, mais c’est “#{@actual}”"
      unless options.nil?
        if options.key?(:retour)
          retour_exists = page.has_css?("h2.page-title a[href=\"#{options[:retour][:route]}\"]", text: options[:retour][:text])
          unless retour_exists
            if page.has_css?('h2.page-title a')
              dretour = options[:retour]
              if dretour.key?(:route)
                unless page.has_css?("h2.page-title a[href=\"#{dretour[:route]}\"]")
                  hrefretour = page.find('h2.page-title a')['href']
                  @errors << "La route du lien retour devrait être `#{dretour[:route]}`, or c'est `#{hrefretour}`"
                end
              end
              if dretour.key?(:text)
                unless page.has_css?('h2.page-title a', text: dretour[:text])
                  textretour = page.find('h2.page-title a').text
                  @errors << "Le texte du lien retour devrait être “#{dretour[:text]}” or c'est “#{textretour}”"
                end
              end
            else
              @errors << "le titre ne contient aucun lien retour"
            end
          end
          ok = ok && retour_exists
        end
      end
    else # Pas de titre
      @errors << "La page n'a pas de titre…"
      ok = false
    end
    ok
  end
  description do
    "Le titre de la page est à peu près “#{expected.source}”."
  end
  failure_message do
    "Mauvaise page : #{@errors.join(VG)}."
  end
end #/have_titre
