# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
if user.guest?
  require_js_module(['jquery','flash'])
end
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}#{UI_TEXTS[:titre_page_inscription]}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id)
      if Form.new.conform?
        case param(:form_id)
        when 'concours-signup-form'
          require_relative '../xmodules/inscription'
          if traite_inscription
            redirect_to("concours/espace_concurrent")
          end
        end
      end
    elsif param(:op) == 'signupconcours'
      # Quand un icarien inscrit clique sur le bouton "S'inscrire au concours"
      require_relative '../xmodules/inscription'
      traite_inscription_icarien
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb("form", self)
  end # /build_body

end #/HTML
