# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "Le Concours de l’atelier Icare"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec

  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
