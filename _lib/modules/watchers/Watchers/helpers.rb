# encoding: UTF-8
=begin
  Extension de la class MainWatchers pour les helper methods
=end
class Watchers
  def listing
    [
      bouton_mark_all_read,
      unread.collect { |watcher| watcher.out(unread:true) },
      read.collect { |watcher| watcher.out }
    ].join
  end #/ listing

  # Retourne le bouton pour tout marquer lu ou rien si aucune
  # notification n'est nouvelle
  def bouton_mark_all_read
    return '' if unread_count == 0
    Tag.div(text:Tag.lien(route:"#{route.to_s}?op=allmarkread", text:'Tout marquer lu'),class:'right mb2 small')
  end #/ bouton_mark_all_read
end #/Watchers
