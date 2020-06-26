# encoding: UTF-8

class HTML
  def titre
    "Pédagogue de l’atelier".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
