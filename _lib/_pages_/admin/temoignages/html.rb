# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "Administration des témoignages"
  end #/titre

  def usefull_links
		[
			# Ici les liens
		]
	end

  # Code à exécuter avant la construction de la page
  def exec
    admin_required

  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
