# encoding: UTF-8
ERRORS.merge!({
  aid_undefined: 'L’identifiant de l’aide à afficher n’est pas défini…'.freeze,
  aid_unfound: 'Aucun fichier ne correspond à cette aide…'.freeze
})

class HTML

  def titre
    if param(:aid)
      unless Aide::DATA_TDM[param(:aid).to_i].nil?
        "#{RETOUR_AIDE}#{EMO_GYROPHARE.page_title}"
      else
        erreur(ERRORS[:aid_unfound])
        "#{RETOUR_AIDE}Aide introuvable".freeze
      end
    else
      erreur(ERRORS[:aid_undefined])
      "#{RETOUR_AIDE}Aide indéfinie".freeze
    end
  end
  # Code à exécuter avant la construction de la page
  def exec

  end
  # Fabrication du body
  def build_body
    @body = AideFile.new(param(:aid)).out
  end
end #/HTML
