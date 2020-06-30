# encoding: UTF-8

class HTML

  # Construction complète de la page
  def build_page
    add_css('./css/_variables.css')
    Page.load(route)
    proceed_exec if self.respond_to?(:exec) # la route chargée
    build_body
    build_header
    build_titre
    build_head
    build_footer
    build_messages
    css = route.home? ? 'home' : ''
    @page = <<-HTML
<!DOCTYPE html>
<html lang="fr" dir="ltr">
  #{head}
  <body class="#{css}" id="top">
    <section id="header" class="#{css}">#{header}</section>
    #{@titre}
    <section id="messages">#{messages}</section>
    <section id="body" class="#{css}">#{body}</section>
    <div style="clear:both"></div>
    #{top_page_button}
    <section id="footer">#{footer}</section>
    #{build_debug}
    #{Admin.section_essais if SHOW_DEVELOPPEMENT_TOOLS}
    #{js_tags}
    #{relocation_if_download}
  </body>
</html>
    HTML
  end


  # Retourne le bouton pour remonter en haut de la page
  def top_page_button
    '<div id="to-top-button-div"><button class="hidden" id="to-top-button">^</a></div>'.freeze
  end #/ top_page_button

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
  <title>Atelier Icare#{@raw_titre ? " | #{@raw_titre}" : ""}</title>
  #{css_tags}
  <script type="text/javascript">#{@raw_js}</script>
</head>
    HTML
  end

  # Fabrication du titre de la page
  def build_titre
    return '' if route.home?
    t = respond_to?(:titre) ? titre : "Titre page manquant"
    @raw_titre = t.dup.safetize
    @titre = "<h2 class=\"page-title\">#{t}</h2>"
  end

  def build_header
    @header = deserb('vues/header', self)
  end

  def build_messages
    @messages = <<-HTML
  #{Noticer.out}
  #{Errorer.out}
    HTML
  end

  # Toutes les pages doivent définir leur méthode `build_body` qui produira
  # la propriété @body (html@body).
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
#{MAIN_LINKS[:plan_s]}
#{Tag.lien(text:'<span class="nowrap">politique de confidentialité</span>', route:'overview/policy')}
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
