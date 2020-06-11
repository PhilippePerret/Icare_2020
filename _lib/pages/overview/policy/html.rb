# encoding: UTF-8

class HTML
  def titre
    "Politique de confidentialité des données".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
