# encoding: UTF-8
class HTML
  def titre
    "Édition du profil"
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    require_module('forms')
    if param(:form_id) == 'profil-form'
      message("Je dois traiter la modification du profil")
    end

  end
  def build_body
    # Construction du body
    @body = user.formulaire_profil
  end
end #/HTML
