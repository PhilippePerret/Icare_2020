# encoding: UTF-8
# frozen_string_literal: true
require_relative '../App'
class HTML
  include StringHelpersMethods

  # Construction complète de la page
  def build_page
    # log("-> HTML#build_page")
    Page.load(route)
    run_ticket if param(:tik) # Est-ce vraiment le meilleur endroit ?
    if self.respond_to?(:exec) # la route chargée
      proceed_exec
    end
    build_body
    build_header
    build_titre
    build_head
    build_footer
    build_messages
    css = route.home? ? 'home' : ''
    @page = <<-HTML.strip
<!DOCTYPE html>
<html lang="fr" dir="ltr">
  #{head}
  <body class="#{css}" id="top">
    <section id="header" class="#{css}" onclick="document.querySelector('section#messages').innerHTML='';this.classList[this.classList.contains('opened')?'remove':'add']('opened');">#{header}</section>
    <section id="messages" onclick="this.innerHTML=''">#{messages}</section>
    #{@titre}
    <section id="body" class="#{css}">#{body}</section>
    <div style="clear:both"></div>
    #{top_page_button}
    <section id="footer">#{footer}</section>
    #{build_debug}
    #{Admin.section_essais if SHOW_DEVELOPPEMENT_TOOLS}
    #{js_tags}
    #{relocation_if_download}
    #{Admin::Toolbox.out if user.admin?}
  </body>
</html>
    HTML
  end


  # Retourne le bouton pour remonter en haut de la page
  def top_page_button
    '<div id="to-top-button-div"><button class="hidden" id="to-top-button">^</a></div>'
  end #/ top_page_button

  # Méthode qui est appelée si les paramètres contiennent 'tikd' qui est un
  # ticket de download de document. Cf. le mode d'emploi pour l'explication.
  def relocation_if_download
    return '' unless param(:tikd)
    # "<script type=\"text/javascript\">setTimeout(()=>{window.location='#{route.to_s}?tik=#{param(:tikd)}'},1000);</script>"
    "<script type=\"text/javascript\">window.location='#{route.to_s}?tik=#{param(:tikd)}';</script>"
  end #/ relocation_if_download

  #
  def build_head
    @head = <<-HTML
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
  <meta name="google-site-verification" content="V_QWKRM4k87RFk3b4UnHnW5k37ev7NJGZSULi_5_dDk" />
  <title>Atelier Icare#{@raw_titre ? "#{SPACE}|#{SPACE}#{@raw_titre}" : ""}</title>
  <base href="#{App::URL}/">
  <link rel="shortcut icon" href="https://www.atelier-icare.net/img/favicon.png?2020" type="image/png">
  <link rel="icon" href="https://www.atelier-icare.net/img/favicon.png?2020" type="image/png">
  #{css_tags}
  <script type="text/javascript">
    #{@raw_js}
    #{protection_injection}
  </script>
</head>
    HTML
  end

  # Fabrication du titre de la page
  def build_titre
    return EMPTY_STRING if route.home?
    tit = nil
    tit = titre if respond_to?(:titre)
    tit || begin
      # @raw_titre = "" # NON, PEUT ÊTRE DÉFINI
      @titre = ""
      return
    end
    ulinks = EMPTY_STRING
    if respond_to?(:usefull_links) && not(usefull_links.nil? || usefull_links.empty?)
      ulinks = DIV_USEFULL_LINKS % {menus: usefull_links.join }
    end
    @raw_titre ||= tit.dup&.safetize
    @titre = "<h2 class=\"page-title\">#{ulinks}#{tit}</h2>"
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

#{Tag.lien(route:'home',text:'atelier icare')}
#{Tag.link(route:'overview/home', text:'en savoir plus')}
#{MainLink[:aide].simple}
#{MainLink[:contact].simple}
#{MainLink[:plan].simple}
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
    return '' if user.nil?
    Tag.div(text:user.pastille_notifications_non_vues({linked:true}), class:'notification-tool')
  end #/ tools_block_notifications


  private

    # Retourne le code Javascript à écrire pour éviter les intrusions par
    # ajax par exemple
    def protection_injection
      data_uuid = UUID.create(user_id: user.id, session_id: session.id)
      <<-JAVASCRIPT.strip
const UUID = "#{data_uuid[:uuid]}";
const UID  = #{user.id};
      JAVASCRIPT
    end #/ protection_injection

# ---------------------------------------------------------------------
#
#   CONSTANTES
#
# ---------------------------------------------------------------------

DIV_USEFULL_LINKS = '<div class="usefull-links"><div class="handler"></div><div class="menus">%{menus}</div></div>'


end
