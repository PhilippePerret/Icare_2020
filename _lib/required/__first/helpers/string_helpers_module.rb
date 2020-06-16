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
