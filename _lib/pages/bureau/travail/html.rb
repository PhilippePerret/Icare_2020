# encoding: UTF-8
require_modules(['user/modules', 'minifaq'])
class HTML
  def titre
    "#{RETOUR_BUREAU+EMO_TRAVAIL.page_title+ISPACE}Votre travail".freeze
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
    # log("user.statut: #{user.statut}")
    @body = deserb("vues/icarien_#{user.statut}", user)
  end
end #/HTML
