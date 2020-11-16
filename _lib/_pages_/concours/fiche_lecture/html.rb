# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    "Votre fiche de lecture"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    add_css('./_lib/_pages_/concours/evaluation/css/fiche_lecture.css')
    require_xmodule('synopsis')
    try_to_reconnect_visitor
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

  def designation_visiteur_courant
    if user.admin?
      "administrateur (#{user.pseudo})"
    elsif user.evaluator?
      "membre du jury (#{evaluator.pseudo} ##{evaluator.id})"
    elsif user.concurrent?
      "concurrent (#{concurrent.pseudo} ##{concurrent.id})"
    else
      "anonyme"
    end
  end #/ designation_visiteur_courant
end #/HTML
