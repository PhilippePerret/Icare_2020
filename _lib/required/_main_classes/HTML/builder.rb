# encoding: UTF-8

class HTML

  # Construction complète de la page
  def build_page
    Page.load(route)
    proceed_exec if self.respond_to?(:exec)
    build_body
    build_header
    build_head
    build_footer
    build_messages
    build_titre
    @page = <<-HTML
<!DOCTYPE html>
<html lang="fr" dir="ltr">
  #{head}
  <body>
    <section id="header" class="#{route.to_s}">#{header}</section>
    #{@titre}
    <section id="messages">#{messages}</section>
    <section id="body">#{body}</section>
    <section id="footer">#{footer}</section>
    #{build_debug}
    #{Admin.section_essais if SHOW_DEVELOPPEMENT_TOOLS}
  </body>
</html>
    HTML
  end

  def build_head
    @head = <<-HTML
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <base href="http://localhost/AlwaysData/Icare_2020/">
  <title>Atelier Icare</title>
  #{css_tags}
</head>
    HTML
  end

  # Fabrication du titre de la page
  def build_titre
    return '' if route.home?
    t = respond_to?(:titre) ? titre : "Titre page manquant"
    @titre = "<h2 class=\"page-title\">#{t}</h2>"
  end

  def build_header
    @header = deserb('vues/tools') + deserb('vues/logo')
  end

  def build_messages
    @messages = <<-HTML
  #{Noticer.out}
  #{Errorer.out}
    HTML
  end

  # Normalement, toutes les pages doivent définir leur méthode `build_body`
  # Donc, si on arrive ici, c'est que la méthode n'a pas été définie et il faut
  # le signaler
  def build_body
    @body = <<-HTML
Le body de la route <code>#{route.to_s}</code> n'est pas défini.
    HTML
  end

  def build_footer
    @footer = <<-HTML
#{MAIN_LINKS[:home]}
#{MAIN_LINKS[:overview]}
#{MAIN_LINKS[:aide]}
#{MAIN_LINKS[:contact]}
    HTML
  end

  def build_debug
    return '' unless SHOW_DEBUG
    <<-HTML
<pre id="debug"><code>
  ROUTE : #{Route.current.route.inspect}
#{Debugger.out}
</code></pre>
    HTML
  end


end
