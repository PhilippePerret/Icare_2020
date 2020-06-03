# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "🚪 Candidater".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
