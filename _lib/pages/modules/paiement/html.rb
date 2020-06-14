# encoding: UTF-8
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
      user.record_paiement
    elsif param(:op) == 'cancel'
      message("ANNULATION du paiement")
    end
  end
  # Fabrication du body
  def build_body
    @body = if param(:op) == 'ok'
              deserb('vues/body_ok', self)
            else
              deserb('vues/body', self)
            end
  end

  def vue_paiement
    deserb('vues/form', self)
  end #/ vue_paiement

  # raccourci
  def absmodule
    @absmodule ||= user.icmodule.absmodule
  end #/ absmodule

end #/HTML
