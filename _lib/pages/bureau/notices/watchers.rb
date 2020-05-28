# encoding: UTF-8
=begin
  Gestion des LISTES de WATCHERS
=end
class Watchers < UserLister

  def under_class
    @under_class ||= Watcher
  end
  def request_items
    @request_items ||= "SELECT * FROM watchers WHERE user_id = #{owner.id}".freeze
  end

end #/Watchers
