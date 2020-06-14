# encoding: UTF-8
require_module('form')
require_module('paiement')
require_module('user/modules')
class HTML
  def titre
    "💳 Paiement".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    if param(:op) == 'downloadiban'
      # Pour télécharger l'IBAN
      # Noter qu'on peut utiliser cette route de n'importe où pour le
      # télécharger :
      #   <a href="modules/paiement?op=downloadiban">Télécharger l'IBAN</a>
      download(File.join(PUBLIC_FOLDER,'IBAN_Icare.pdf'), 'IBAN_Icare.zip')
    elsif param(:op) == 'ok'
      message("Retour OK de paypal, on peut prendre en compte le paiement")
    elsif param(:op) == 'cancel'
      message("ANNULATION du paiement, on ne fait rien")
    else
      # On passe certainement ici lorsque l'on arrive sur la page, en ne
      # venant ni pour télécharge l'IBAN ni pour conclure la transaction de
      # paiement.
      AIPaiement.init_paiement
    end
  end
  # Fabrication du body
  def build_body
    @body = if param(:op) == 'ok'
              deserb('body_ok', self)
            else
              deserb('body', self)
            end
  end

  # Helper pour la vue
  def paiement
    AIPaiement.current
  end #/ paiement

  def vue_paiement
    deserb('vues/paiement', self)
  end #/ vue_paiement

end #/HTML
