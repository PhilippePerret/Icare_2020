# encoding: UTF-8
# frozen_string_literal: true
require './_lib/_pages_/concours/evaluation/lib/Synopsis'
require './_lib/_pages_/concours/evaluation/lib/FicheLecture'
class HTML
  def titre
    "Votre fiche de lecture"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    add_css('./_lib/_pages_/concours/evaluation/css/fiche_lecture.css')
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
