# encoding: UTF-8
=begin
  Class AIPaiement
  -----------------
  Pour le paiement au sein de l'atelier Icare

  Note : il faut que ce module puisse fonctionner de façon autonome afin
  de pouvoir s'en servir par exemple dans les outils administrateurs quand
  on doit marquer un paiement effectué.
=end
require_module('icmodules')

class AIPaiement < ContainerClass
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def table
    @table = 'paiements'
  end #/ table

end # /<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def owner
  @owner ||= User.get(user_id)
end #/ owner
def icmodule
  @icmodule ||= IcModule.get(icmodule_id)
end #/ icmodule
def date_next_paiement
  @date_next_paiement ||= begin
    formate_date(icmodule.next_paiement_at) unless icmodule.next_paiement_at.nil?
  end
end #/ date_next_paiement

# Traitement du paiement APRÈS retour de paypal
# ---------------------------------------------
# où le module a été
# réglé ou bien après confirmation de bonne réception pour un
# virement.
# La méthode :
#   - crée un nouveau watcher de paiement si c'est un module à durée indéterminée
#   - envoie la facture à l'icarien
#   - marque l'icarien réel s'il était à l'essai (en appelant la méthode set_real
#     qui produit une actualité)
def traite
  log("-> AIPaiement#traite")

  # On détruit le watcher de paiement courant
  # NOTE Noter que si, à l'avenir, on permet plusieurs modules en même temps,
  # il y aura une confusion ici, le premier watcher de paiement sera détruit.
  # Il faudrait appeler la méthode remove_watcher_paiement avec l'identifiant
  # du module concerné.
  dwatcher = owner.remove_watcher_paiement

  # Si c'est un suivi de projet, faire le prochain watcher
  if icmodule.suivi?
    next_paiement =  dwatcher[:triggered_at] + 31.days
    owner.watchers.add('paiement_module', {objet_id: icmodule.id, triggered_at: next_paiement, vu_user:false})
    @date_next_paiement = formate_date(next_paiement)
  end

  # Si l'utilisateur était à l'essai, il devient un vrai icarien
  owner.set_real if owner.essai?

  # Envoyer la facture à l'utilisateur (avec un lien vers la politique
  # de confidentialité)
  owner.send_mail({
    subject: MESSAGES[:votre_facture],
    message: deserb('mail_user', self)
  })

  # M'avertir qu'un nouveau paiement a été effectué
  phil.send_mail({
    subject: MESSAGES[:nouveau_paiement_icarien],
    message: deserb('mail_admin', self)
  })
end #/ traite

# Retourne la facture pour le paiement
def facture
  log("data aipaiement : #{self.data.inspect}")
  log("owner data : #{owner.data}")
  <<-HTML
<table id="facture-#{id}" cellpadding="0" cellspacing="0" class="facture">
  <tr>
    <td colspan="2">FACTURE N°#{facture_id}</td>
  </tr>
  <tr>
    <td>Délivrée le</td><td>#{formate_date(created_at)}</td>
  </tr>
  <tr>
    <td>Délivrée par</td><td>Atelier Icare (atelier d’écriture en ligne : https://www.atelier-icare.net)</td>
  </tr>
  <tr>
    <td>À l'ordre de</td><td>#{owner.patronyme||owner.pseudo} (#{owner.mail})</td>
  </tr>
  <tr>
    <td>Objet</td><td>Module d’apprentissage “#{icmodule.ref}”</td>
  </tr>
  <tr>
    <td>MONTANT TTC</td><td>#{montant} €</td>
  </tr>
</table>
  HTML
end #/ facture

# La version mail de la facture
def facture_mail
  <<-HTML
<pre><code>
.........................................................
.
. FACTURE N°#{facture_id}
.........................................................
.
. À L'ORDRE DE : #{owner.patronyme||owner.pseudo} (#{owner.mail})
.
. DÉLIVRÉ LE   : #{formate_date}
.
.         PAR  : Atelier Icare (atelier d'écriture en
.                ligne : https://www.atelier-icare.net)
.
. OBJET        : Module d'apprentissage
.
.  DÉSIGNATION : #{icmodule.ref.titleize}
.
. MONTANT TTC  : #{montant} €
.
.........................................................
</code></pre>
  HTML
end #/ facture_mail

end #/AIPaiement
