# encoding: UTF-8

class HTML
  def titre
    "#{RETOUR_ADMIN}#{EMO_ESPIONNE.page_title} Traceur du site".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  # Fabrication du body
  def build_body
    @body = <<-HTML.freeze
<p class="explication">Ce traceur permet de suivre en direct les connexions et les problèmes sur le site distant.</p>
<div class="only-message">Pour lancer le traceur du site, ouvrir une fenêtre Terminal et taper <code>icare trace</code>.</div>
    HTML
  end
end #/HTML
