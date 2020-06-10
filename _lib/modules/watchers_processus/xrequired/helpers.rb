# encoding: UTF-8
=begin
  Helpers pour rédiger les mails et les notifications
=end

# Pour placer un lien absolu vers la collection Narration
def collection_narration(titre = nil)
  Tag.lien(text:titre||'Collection Narration', route:'http://www.scenariopole.fr/narration', target:true)
end #/ collection_narration
