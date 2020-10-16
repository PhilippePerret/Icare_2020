# encoding: UTF-8
# frozen_string_literal: true

class HTML
  def titre
    "Résultats du concours de synopsis"
  end #/titre
  
def usefull_links
		[
			# Ici les liens
		]
	end

  # Code à exécuter avant la construction de la page
  def exec
    
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
