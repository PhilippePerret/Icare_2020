# encoding: UTF-8
=begin
  Extension de la class MainWatchers pour les helper methods
=end
class MainWatchers
  def listing
    [
      unread.collect { |watcher| watcher.out(unread:true) },
      read.collect { |watcher| watcher.out }
    ].join
  end #/ listing
end #/Watchers
