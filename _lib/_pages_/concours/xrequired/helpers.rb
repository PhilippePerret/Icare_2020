# encoding: UTF-8
# frozen_string_literal: true
=begin
  Helpers
=end
class HTML

  # Retourne le code HTML du bouton pour rejoindre le formulaire
  # d'inscription au concours.
  def bouton_formulaire
    cont = Tag.link(class:'btn main green pd1', text:"Inscription au concours", route:"concours/form")
    Tag.div(class:'mt2 mb2 center', text: cont)
  end #/ bouton_formulaire

  def bouton_retour
    @bouton_retour ||= Tag.retour(route:"concours/home", titre:"Le Concours")
  end #/ bouton_retour
end #/HTML
