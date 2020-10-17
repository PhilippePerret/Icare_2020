# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}Dossier du concours"
  end #/titre

  # def usefull_links
	# 	[
	# 		Tag.link(route:"concours/accueil", text:"Accueil du concours")
	# 	]
	# end

  # Code à exécuter avant la construction de la page
  def exec

  end # /exec

  # Fabrication du body
  def build_body
    @body = kramdown('body', self)
  end # /build_body

end #/HTML
