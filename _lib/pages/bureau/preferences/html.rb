# encoding: UTF-8
class HTML
  def titre
    "#{RETOUR_BUREAU}🏠 Vos préférences".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
  end
  def build_body
    # Construction du body
    @body = <<-HTML
<p>Cette page vous permet de régler vos préférences.</p>
    HTML
  end
end #/HTML
