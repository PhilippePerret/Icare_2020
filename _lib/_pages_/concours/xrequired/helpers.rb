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
  # Note : pas de formulaire d'inscription quand on est entre la phase 2 et 5
  def bouton_formulaire
    phase = Concours.current.phase
    return "" if phase.between?(2,5)
    btn_key = phase < 2 ? :concours_bouton_inscription : :concours_btn_signup_next
    cont = Tag.link(class:'btn main green pd1', text:UI_TEXTS[btn_key], route:"concours/inscription")
    Tag.div(class:'mt2 mb2 center', text: cont) + div_avantages_signup_before
  end #/ bouton_formulaire

  def div_avantages_signup_before
    cont = Tag.link(route:"concours/faq", text: "☞ Les avantages d'une inscription anticipée")
    Tag.div(class:"mt2 center", text:cont)
  end #/ div_avantages_signup_before

  # Produit un bouton pour s'identifier ou, si on est identifié, pour
  # rejoindre son espace personnel
  def bouton_login_or_espace
    if concurrent
      cont = Tag.link(route:"concours/espace_concurrent", text:"Rejoindre votre espace.")
      Tag.div(class:'center small', text:"Vous êtes identifié#{concurrent.femme? ? 'e' : ''}. #{cont}")
    else
      cont = Tag.link(route:"concours/identification", text:UI_TEXTS[:concours_btn_identifiez_vous])
      Tag.div(class:'center small', text: "Déjà inscrite ou inscrit ?… #{cont} !")
    end
  end #/ bouton_login

  # Produit un bouton pour le titre, pour revenir à l'accueil du concours
  def bouton_retour
    @bouton_retour ||= Tag.retour(route:"concours/accueil", titre:"Le Concours")
  end
  def bouton_retour_espace_perso
    @bouton_retour_espace_perso ||=  Tag.retour(route:"concours/espace_concurrent", titre:"")
  end
end #/HTML
