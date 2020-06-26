# encoding: UTF-8
=begin
  Méthodes d'helpers générales qui permettent de traiter tous les textes

  Note : toutes les classes héritant de ContainerClass héritent de ces méthodes
=end
module StringHelpersMethods

def fem(key)
  user.fem(key)
end #/ fem

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
  wt = TravailType.get_by_name(rubrique, name).travail
  # Dans ce travail type, il ne faut qu'évaluer les #{}. Il ne faut surtout
  # pas faire une correction complète, sinon il y aurait une correction d'une
  # correction avec tous les désagréments que l'on connait.
  AIKramdown.evaluate(wt, self)
end #/ travail_type

=begin
  Helpers pour rédiger les mails et les notifications
=end

# ---------------------------------------------------------------------
#
#   SECTIONS DU SITE
#
# ---------------------------------------------------------------------

def bureau(titre = nil)
  Tag.lien(route: "bureau/home", text:titre||'bureau de travail')
end #/ votre_bureau

def quai_des_docs(titre = nil)
  @quai_des_docs ||= Tag.lien(route:'qdd/home', text:titre||'Quai des docs').freeze
end #/ Quai_des_docs

def hall_of_fame(titre = nil)
  @hall_of_fame ||= Tag.lien(route:'overview/reussites', text:titre||'Hall of Fame').freeze
end #/ Quai_des_docs

def profil(titre = nil)
  Tag.lien(text:titre||'profil'.freeze, route:'user/profil')
end #/ profil

def section_aide(titre = nil)
  Tag.route(:aide, titre||'section Aide')
end #/ section_aide

def section_preferences(titre = nil)
  Tag.lien(text:titre||'section Préférences'.freeze, route:'bureau/preferences')
end #/ section_preferences

def section_modules(titre = nil)
  Tag.lien(text:titre||'section “Modules d’apprentissage”'.freeze, route:'modules/home')
end #/ section_modules

# ---------------------------------------------------------------------
#
#   LIEUX HORS ATELIER
#
# ---------------------------------------------------------------------

# Pour placer un lien absolu vers la collection Narration
def collection_narration(titre = nil)
  Tag.lien(text:titre||'Collection Narration', route:'http://www.scenariopole.fr/narration', target:true)
end #/ collection_narration

def scenariopole(titre = nil)
  Tag.lien(text:titre||'Scénariopole', route:'http://www.scenariopole.fr')
end #/ scenariopole


def politique_confidentialite(titre = nil)
  Tag.lien(text:titre||'politique de confidentialité'.freeze, route:'overview/policy', target:true)
end #/ politique_confientialite

# ---------------------------------------------------------------------
#
#   TEXTES DIVERS
#
# ---------------------------------------------------------------------


# Signature pour les mails
def le_bot
  @le_bot ||= '🤖 Le Bot de l’atelier Icare'.freeze
end #/ Le_bot

def srps(titre=nil)
  Tag.lien(text:titre||'Savoir rédiger et présenter son scénario', route:'http://encresdesiagne.fr/index.php?id_product=32&id_product_attribute=0&rewrite=savoir-rediger-et-presenter-son-scenario&controller=product', class:'livre')
end #/ srps

def contact(titre=nil)
  Tag.lien(text:titre||'formulaire de contact', route:'contact')
end #/ contact

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


end #/module StringHelpersMethods

# Pour obtenir l'accès à ces méthodes partout avec :
#   StringHelper#<methode>
class StringHelper
  extend StringHelpersMethods
end
