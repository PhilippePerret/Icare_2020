# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    "#{EMO_TITRE}Concours de synopsis de l’atelier Icare"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    try_reconnect_concurrent
  end # /exec

  # Fabrication du body
  def build_body
    partial = Concours.current.started? ? 'body' : 'none'
    @body = deserb(partial, self)
  end # /build_body

end #/HTML
