# encoding: UTF-8
require_modules(['user/modules','watchers'])
SANDBOX = TESTS || OFFLINE

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
      # Avant de procéder au téléchargement de l'IBAN, on crée un watcher qui
      # permettra à l'icarien de prévenir Phil que son paiement a été effectué.
      user.remplace_watcher_paiement_par_annonce_virement
      download(File.join(PUBLIC_FOLDER,'IBAN_Icare.pdf'), 'IBAN_Icare.zip')
    elsif param(:op) == 'per_virement'
      user.remplace_watcher_paiement_par_annonce_virement
    elsif param(:op) == 'ok'
      # Le paiement a été effectué avec succès, on peut enregistrer
      # ce paiement pour l'user
      user.add_paiement
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

  def paiement
    @paiement ||= user.paiement
  end #/ paiement

  def facture
    @facture ||= paiement.facture
  end #/ facture

  def facture_mail
    @facture_mail ||= paiement.facture_mail
  end #/ facture_mail

  # raccourci
  def absmodule
    @absmodule ||= user.icmodule.absmodule
  end #/ absmodule

end #/HTML
