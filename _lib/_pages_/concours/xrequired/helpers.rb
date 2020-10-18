# encoding: UTF-8
# frozen_string_literal: true
=begin
  Helpers
=end

EMO_BLASON = Emoji.get('objets/blason')
EMO_TITRE = "#{EMO_BLASON.page_title}#{ISPACE}"

class HTML

  # Retourne le code HTML du bouton pour rejoindre le formulaire
  # d'inscription au concours.
  def bouton_formulaire
    cont = Tag.link(class:'btn main green pd1', text:"Inscription au concours", route:"concours/inscription")
    Tag.div(class:'mt2 mb2 center', text: cont)
  end #/ bouton_formulaire

  # Produit un bouton pour s'identifier
  def bouton_login
    cont = Tag.link(route:"concours/identification", text:"Identifiez-vous")
    Tag.div(class:'right', text: "Déjà inscrite ou inscrit ?… #{cont} !")
  end #/ bouton_login

  # Produit un bouton pour le titre, pour revenir à l'accueil du concours
  def bouton_retour
    @bouton_retour ||= Tag.retour(route:"concours/accueil", titre:"Le Concours")
  end #/ bouton_retour

end #/HTML
