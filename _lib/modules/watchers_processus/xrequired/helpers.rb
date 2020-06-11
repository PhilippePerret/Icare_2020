# encoding: UTF-8
=begin
  Helpers pour rédiger les mails et les notifications
=end

# Pour placer un lien absolu vers la collection Narration
def collection_narration(titre = nil)
  Tag.lien(text:titre||'Collection Narration', route:'http://www.scenariopole.fr/narration', target:true)
end #/ collection_narration

def quai_des_docs(titre = nil)
  @quai_des_docs ||= Tag.lien(route:'qdd/home', text:titre||'Quai des docs').freeze
end #/ Quai_des_docs

# Signature pour les mails
def Le_Bot
  @LeBot ||= '🤖 Le Bot de l’atelier Icare'.freeze
end #/ Le_bot