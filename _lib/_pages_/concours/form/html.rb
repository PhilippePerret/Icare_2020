# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{bouton_retour}Inscription au concours"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id) && param(:form_id) == 'concours-form'
      form = Form.new
      if form.conform?
        traite_inscription(form)
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb("form", self)
  end # /build_body

  def traite_inscription(form)
    log("-> traitement de l'inscription")
    message("Traitement de l'inscription à implémenter")
  end #/ traite_inscription

end #/HTML
