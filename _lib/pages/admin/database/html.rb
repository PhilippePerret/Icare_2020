# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "#{RETOUR_ADMIN}#{EMO_ARMOIRE.page_title} Base de données".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    admin_required
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
