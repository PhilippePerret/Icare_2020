# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "💳 Paiement".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    if param(:op) == 'downloadiban'
      download(File.join(PUBLIC_FOLDER,'IBAN_Icare.pdf'), 'IBAN_Icare.zip')
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end

  def vue_paiement
    deserb('vues/paiement', self)
  end #/ vue_paiement
end #/HTML
