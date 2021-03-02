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
    "#{bouton_retour}#{EMO_TITRE}Palmarès du concours de synopsis #{param(:an) || ANNEE_CONCOURS_COURANTE}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    try_to_reconnect_visitor(required = false)
    @concours = param(:an) ? Concours.new(param(:an)) : Concours.current
    require_xmodule('calculs')
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
