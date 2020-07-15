# encoding: UTF-8
class User

  attr_reader :paiement # Instance AIPaiement (quand on revient du paiement)

  def has_paiement?
    true # TODO
  end #/ has_paiement?
  def paiement_overcomen?
    true # TODO
  end #/ paiement_overcomen?

  # On ajoute un paiement pour le module +icmodule_id+ qu'on peut passer
  # en argument, dans le cas d'un paiement par virement qui serait enregistré
  # plus tard par moi alors qu'un autre module serait déjà en cours.
  def add_paiement(icmodule_id = nil)
    icmod = icmodule_id.nil? ? icmodule : IcModule.get(icmodule_id)
    data = {
      user_id:      self.id,
      icmodule_id:  icmod.id,
      objet:        icmod.ref,
      facture_id:   (3.5*self.id).to_i.to_s.rjust(8,'0'), # ID de la facture
      montant:      icmod.absmodule.tarif
    }
    @paiement = AIPaiement.create_with_data(data)
    @paiement.traite
  end #/ add_paiement

  # Quand un icarien à l'essai effectue son premier paiement, il
  # devient réel, donc un "vrai" icarien. On le marque dans ses
  # options et on produit une actualité
  def set_real
    set_option(24, 1, true)
    Actualite.add('REALICARIEN', self.id, MESSAGES[:actu_real] % {pseudo:pseudo, e:fem(:e), ne:fem(:ne)})
  end #/ set_real

  # En cas de volonté de paiement par IBAN
  # pour ajouter le watcher permettant d'annoncer le virement effectué et pour
  # détruire le watcher courant de paiement.
  def remplace_watcher_paiement_par_annonce_virement
    dwatcher = db_get('watchers', {user_id: id, wtype:'paiement_module'})
    self.watchers.add('annonce_virement', objet_id: dwatcher[:objet_id])
    db_delete('watchers', dwatcher[:id])
    message(MESSAGES[:notification_to_inform_phil_when_virement])
    self.send_mail(subject:MESSAGES[:subject_mail_paiement_per_virement], message:deserb('mail_user_per_virement', self))
  end #/ remplace_watcher_paiement_par_annonce_virement

end #/User

class IcModule < ContainerClass
  def montant_humain
    @montant_humain ||= "#{absmodule.tarif}#{ISPACE}€"
  end #/ montant_humain
end #/IcModule
