# encoding: UTF-8
class HTML
  def titre
    "#{lien_retour_bureau} 🏠 Votre profil"
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
  end
  def build_body
    # Construction du body
    @body = deserb('profil', user)
  end
end #/HTML
