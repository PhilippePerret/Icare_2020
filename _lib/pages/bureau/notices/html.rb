# encoding: UTF-8
class HTML
  def titre
    "#{lien_retour_bureau} 🏠 Notifications"
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
  end
  def build_body
    # Construction du body
    @body = deserb('body', user)
  end
end #/HTML
