# encoding: UTF-8

class HTML
  def titre
    "#{RETOUR_ADMIN}🦹‍♀️ Espion".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  # Fabrication du body
  def build_body
    @body = <<-HTML
<p>Cette page doit permettre de lancer l'espion de l'atelier.</p>
    HTML
  end
end #/HTML
