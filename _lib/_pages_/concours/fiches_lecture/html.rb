# encoding: UTF-8
# frozen_string_literal: true
=begin
  Cette section affiche les fiches de lecture du concurrent et lui permet
  de les télécharger, pendant x années (5 ans).
=end
class HTML
  def titre
    "Vos fiches de lecture"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    add_css('./_lib/_pages_/concours/evaluation/css/fiche_lecture.css')
    require_xmodule('synopsis')
    try_to_reconnect_visitor(required = true)
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

  def code_css_fiche_lecture
    "<style media=\"screen\" type=\"text/css\">#{css_fiche_lecture}</style>"
  end #/ code_css_fiche_lecture

  # OUT   Code CSS qu'il faut ajouter à la page quand c'est une seule
  #       fiche de lecture qui est affichée.
  def css_fiche_lecture
    <<-CSS
* {color:black!important}
@media print {section#header {display:none;}}
section#header,section#footer,h2.page-title,.noprint{display:none}
.header.hidden,.detail.hidden{display:block!important}
div#lien_revenir{display:normal}
    CSS
  end #/ css_fiche_lecture
end #/HTML
