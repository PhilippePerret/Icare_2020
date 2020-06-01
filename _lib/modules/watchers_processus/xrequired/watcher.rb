# encoding: UTF-8
=begin
  Extention à la class Watcher pour jouer le watcher
=end
class Watcher

  # Méthode principale pour afficher un watcher
  def out
    message "Affichage du watcher à implémenter"
    return '<p>Watcher</p>'
  end #/ out

  # Méthode principale pour lancer un watcher
  # Note : un watcher est lancé quand on joue le bouton de soumission de
  # sa notification (principalement)
  def run
    message "Watcher à jouer"
  end #/ run

end #/Watcher
