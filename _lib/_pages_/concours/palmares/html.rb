# encoding: UTF-8
# frozen_string_literal: true
=begin
  Partie qui affiche les résultats ou une page d'attente des
  résultats.
  En tant qu'administrateur, on peut toujours avoir la page des résultats
  affichés.
=end

class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}Résultats du concours de synopsis"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    @concours = Concours.current
    require_xmodule('synopsis/Synopsis')
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
