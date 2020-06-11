# encoding: UTF-8

class HTML

  # Construction complète de la page
  def build_page
    add_css('./css/_variables.css')
    Page.load(route)
    proceed_exec if self.respond_to?(:exec) # la route chargée
    build_body
    build_header
    build_head
    build_footer
    build_messages
    build_titre
    css = route.home? ? 'home' : ''
    @page = <<-HTML
<!DOCTYPE html>
<html lang="fr" dir="ltr">
  #{head}
  <body class="#{css}">
    <section id="header" class="#{css}">#{header}</section>
    #{@titre}
    <section id="messages">#{messages}</section>
    <section id="body" class="#{css}">#{body}</section>
    <section id="footer">#{footer}</section>
    #{build_debug}
    #{Admin.section_essais if SHOW_DEVELOPPEMENT_TOOLS}
    #{js_tags}
    #{relocation_if_download}
  </body>
</html>
    HTML
  end

  # Méthode qui est appelée si les paramètres contiennent 'tikd' qui est un
  # ticket de download de document. Cf. le mode d'emploi pour l'explication.
  def relocation_if_download
    return '' unless param(:tikd)
    # "<script type=\"text/javascript\">setTimeout(()=>{window.location='#{route.to_s}?tik=#{param(:tikd)}'},1000);</script>"
    "<script type=\"text/javascript\">window.location='#{route.to_s}?tik=#{param(:tikd)}';</script>"
  end #/ relocation_if_download

  def build_head
    @head = <<-HTML
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <base href="http://localhost/AlwaysData/Icare_2020/">
  <title>Atelier Icare</title>
  #{css_tags}
  <script type="text/javascript">#{@raw_js}</script>
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
    @header = deserb('vues/tools', self) + deserb('vues/logo')
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
#{MAIN_LINKS[:overview_s]}
#{MAIN_LINKS[:aide_s]}
#{MAIN_LINKS[:contact_s]}
#{Tag.lien(text:'politique de confidentialité', route:'overview/policy')}
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

  # @helper
  # Retourne le bloc à coller dans la barre d'outils lorsque
  # l'utilisateur est identifié et qu'on a des notifications.
  def tools_block_notifications
    Tag.div(text:user.pastille_notifications_non_vues({linked:true}), class:'notification-tool')

  end #/ tools_block_notifications
end
