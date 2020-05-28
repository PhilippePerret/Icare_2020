# encoding: UTF-8
require_module('user/modules')
class HTML
  def titre
    "#{lien_retour_bureau} 🏠 Votre travail"
  end
  def exec
    icarien_required
    # Code à exécuter avant la construction de la page
    exec_operation if param(:ope)
  end
  def build_body
    # Construction du body
    # user.set_option(16,2)
    require_module(:travail) if user.actif?
    @body = deserb("vues/icarien_#{user.statut}", user)
  end
end #/HTML
