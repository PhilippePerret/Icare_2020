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

def hall_of_fame(titre = nil)
  @hall_of_fame ||= Tag.lien(route:'overview/reussites', text:titre||'Hall of Fame').freeze
end #/ Quai_des_docs

def politique_confidentialite(titre = nil)
  Tag.lien(text:titre||'politique de confidentialité des données'.freeze, route:'overview/policy', target:true)
end #/ politique_confientialite

def profil(titre = nil)
  Tag.lien(text:titre||'profil'.freeze, route:'user/profil')
end #/ profil

def section_preferences(titre = nil)
  Tag.lien(text:titre||'section Préférences'.freeze, route:'bureau/preferences')
end #/ section_preferences

# Signature pour les mails
def le_bot
  @le_bot ||= '🤖 Le Bot de l’atelier Icare'.freeze
end #/ Le_bot
