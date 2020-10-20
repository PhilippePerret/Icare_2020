# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "Estimation des synopsis"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    admin_required

  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
