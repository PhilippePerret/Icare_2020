# encoding: UTF-8
# frozen_string_literal: true
require_modules(['user/modules','watchers'])
SANDBOX = TESTS || OFFLINE

class HTML
  def titre
    "#{Emoji.get('objets/cb').page_title+ISPACE}Paiement"
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
      user.simple_watcher_pour_virement
      redirect_to 'bureau/notifications'
    elsif param(:op) == 'onApprove'
      log("-> paiement effectué")
      # TODO Il faut en fait aller directement sur une autre page, pour ne
      # pas avoir de clic à nouveau sur le bouton (ou alors essayer de faire
      # disparaitre le bouton dans la page ?)
      # Le paiement a été effectué avec succès, on peut enregistrer
      # ce paiement pour l'user
      paiement_id = param(:paiement_id)
      log("---- paiement_id: #{paiement_id}")

      MyPayPal.get_access_token

      res = MyPayPal.exec_request({
        route: "v2/checkout/orders/#{paiement_id}"
      })
      # log("---- Retour paiement: #{res.inspect}")
      # Pour que le paiement soit OK, il faut que :
      # res["status"] == "COMPLETED"
      if res.key?('status') && res['status'] == 'COMPLETED'
        user.add_paiement
        @body_name = 'on_ok'
      else
        @body_name = 'on_error'
      end
    elsif param(:op) == 'cancel'
      @body_name = 'on_cancel'
    end
  end

  # Fabrication du body
  def build_body
    @body = deserb("vues/#{@body_name||'body_form'}", self)
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
