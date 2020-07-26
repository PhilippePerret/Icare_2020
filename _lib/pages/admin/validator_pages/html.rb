# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "#{Emoji.get('machine/validator').page_title+ISPACE}Inspecteur (validateur de page)".freeze
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    admin_required

  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb(STRINGS[:body], self)
  end # /build_body

end #/HTML
