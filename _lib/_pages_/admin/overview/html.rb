# encoding: UTF-8

class HTML
  def titre
    "#{RETOUR_ADMIN}#{EMO_RAPPORT.page_title}#{ISPACE}Aperçu de l’atelier".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
