# encoding: UTF-8
require_modules(['absmodules','form', 'user/helpers','icmodules'])
class HTML
  def titre
    "🗃️ Le Quai des Docs".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    log('-> exec')
    icarien_required
    if param(:form_id)
      form = Form.new
      traite_formulaire_search(form) if form.conform?
    else
      log(' pas de formulaire (dans exec)')
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end

  def listing
    @listing # Peut être défini par `traite_formulaire_search`
  end #/ listing

end #/HTML
