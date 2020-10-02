# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{RETOUR_ADMIN}Outils"
  end
  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    add_js('./js/modules/jquery.js')
    add_js('./js/modules/ajax.js')
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
