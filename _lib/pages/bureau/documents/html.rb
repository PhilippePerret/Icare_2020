# encoding: UTF-8
class HTML
  def titre
    "#{RETOUR_BUREAU}🏠 vos documents".freeze
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
