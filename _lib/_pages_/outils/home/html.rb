# encoding: UTF-8
# frozen_string_literal: true

class HTML
  def titre
    "Outils d’écriture"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec

  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
