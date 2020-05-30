# encoding: UTF-8

class HTML
  def titre
    "🗃️ Le Quai des Docs".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required

  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
