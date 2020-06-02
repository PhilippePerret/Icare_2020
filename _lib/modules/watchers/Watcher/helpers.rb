# encoding: UTF-8
=begin
  Helpers pour construire les notifications
=end
class Watcher < ContainerClass

  # Bouton pour jouer (runner) le watcher, c'est-à-dire jouer sa
  # commande 'run' (donc la méthode définie par objet_class#processus dans
  # le dossier des données du watcher)
  def button_run(titre, options = nil)
    Tag.lien(route:"#{route.to_s}?op=run&wid=#{id}", titre: titre, class:'main')
  end #/ button_run

  # Bouton pour contre-jouer (unrunner) le watcher, c'est-à-dire pour
  # jouer la méthode 'unrun' (donc la méthode définie par :
  # <objet_class>#contre_<processus>) dans le dossier des données du watcher
  def button_unrun(titre, options = nil)
    Tag.lien(route:"#{route.to_s}?op=unrun&wid=#{id}", titre: titre)
  end #/ button_unrun
  
end #/Watcher < ContainerClass
