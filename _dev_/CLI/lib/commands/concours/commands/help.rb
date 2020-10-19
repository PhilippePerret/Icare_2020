# encoding: UTF-8
# frozen_string_literal: true
class Concours
class << self
  def help
    clear
    puts <<-HELP.bleu
=== AIDE POUR LA COMMANDE 'concours' ===

#{'icare concours start'.jaune} (ou #{'icare concours annonce'.jaune})
    Pour démarrer le concours. Cela produit plusieurs choses :
    1) ça permet de rejoindre la partie du site décrivant le concours.
    2) Ça prévient tous les inscrits que le concours est lancé.

#{'icare concours stop'.jaune}
    Pour arrêter le concours (après les résultats)
    1) "ferme" la section de l'atelier du concours
    2) remercie les participants d'avoir participé
    HELP
  end #/ help
end # /<< self
end #/Concours
