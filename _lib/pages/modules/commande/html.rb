# encoding: UTF-8
require_module('form')
class HTML
  attr_reader :absmodule

  def titre
    "#{RETOUR_MODULES+Emoji.get('objets/notebook').page_title+ISPACE}Commande d’un module".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    require_module('absmodules')
    @absmodule = AbsModule.get(param(:mid))
  end
  # Fabrication du body
  def build_body
    @body = deserb("body_#{user.guest? ? 'nobody' : 'icarien'}".freeze, self)
  end
end #/HTML
