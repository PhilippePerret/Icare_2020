# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    "#{EMO_TITRE}Le Concours annuel de l’atelier Icare"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec

  end # /exec

  # Fabrication du body
  def build_body
    partial = ONLINE ? 'none' : 'body'
    @body = deserb(partial, self)
  end # /build_body

end #/HTML
