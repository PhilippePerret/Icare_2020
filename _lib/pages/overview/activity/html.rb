# encoding: UTF-8

class HTML
  def titre
    "Activité de l'atelier Icare".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
