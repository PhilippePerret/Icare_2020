# encoding: UTF-8
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
    "La page ne contient aucun message d'erreur.".freeze
  end
  failure_message do
    "La page ne devrait contenir aucune erreur. Elle contient : #{@erreurs_messages}".freeze
  end
end
RSpec::Matchers.alias_matcher :have_aucune_erreur, :have_no_erreur


RSpec::Matchers.define :have_error do |err_msg|
  match do |page|
    err_msg || raise("Il faut fournir le message d'erreur à trouver !".freeze)
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
      @ajout = "Elle ne contient aucun message d’erreur.".freeze
      return false
    end
  end
  failure_message do
    "La page devrait contenir le message d’erreur “#{err_msg}”. #{@ajout}".freeze
  end
  description do
    "La page contient bien le message d’erreur “#{err_msg}”.".freeze
  end
end
RSpec::Matchers.alias_matcher :have_erreur, :have_error

RSpec::Matchers.define :have_message do |msg|
  match do |page|
    msg || raise("Il faut fournir le message à trouver !".freeze)
    if page.has_css?('section#messages div.notices')
      # if page.has_css?('div.errors', text: /#{Regexp.escape(msg)}/)
      if page.has_css?('section#messages div.notices', text: msg.gsub(/ /,' '))
        return true
      else
        actua_msg = page.find('section#messages div.notices').text
        @ajout = "En revanche, le message “#{actua_msg}” a été trouvé."
        return false
      end
    else
      @ajout = "Elle ne contient aucun message.".freeze
      return false
    end
  end
  failure_message do
    "La page devrait contenir le message “#{msg}”. #{@ajout}".freeze
  end
  description do
    "La page contient bien le message  “#{msg}”.".freeze
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
            next false if dwat[:created_at] < params[:after]
          end
          if params.key?(:before)
            next false if dwat[:created_at] > params[:before]
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
        selector = "div.watcher#watcher-#{wid}"
        selector << ".unread" if params[:unread]
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
