# encoding: UTF-8
=begin
  Méthodes d'helpers générales qui permettent de traiter tous les textes

  Note : toutes les classes héritant de ContainerClass héritent de ces méthodes
=end
module StringHelpersMethods

# Retourne un lien vers un mot du scénodico
def mot(mot_id, mot_mot, options = nil)
  options ||= {}
  options.merge!(text: mot_mot, id:mot_id)
  Tag.mot(options)
end #/ mot

def film(film_id, film_titre = nil, options = nil)
  options ||= {}
  options.merge!(text: film_titre, id:film_id)
  Tag.film(options)
end #/ film

# Pour insérer le travail type
def travail_type(rubrique, name)
  "Je retourne le travail type"
end #/ travail_type

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
  Tag.lien(text:titre||'politique de confidentialité'.freeze, route:'overview/policy', target:true)
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

# ---------------------------------------------------------------------
#
#   Pour récupérer les erreurs d'appel à la méthode site
#
# ---------------------------------------------------------------------
class OldSite
  def method_missing method_name, *args, &block
    send_error("Appel de l'ancienne instance `site`", {
      'méthode appelée' => method_name,
      'arguments' => args
    })
    "[Impossible de retourner site.#{method_name} — l'administration a été prévenue]"
  end #/ missing_method
end #/OldSite
def site
  @site ||= OldSite.new
end #/ site
end
