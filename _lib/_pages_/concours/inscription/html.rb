# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}#{UI_TEXTS[:titre_page_inscription]}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id)
      form = Form.new
      if form.conform?
        case param(:form_id)
        when 'concours-signup-form'
          if traite_inscription(form)
            redirect_to("concours/concurrent")
          end
        end
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb("form", self)
  end # /build_body

end #/HTML
