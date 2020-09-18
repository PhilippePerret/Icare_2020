# encoding: UTF-8
=begin
  Module operation administrateur permettant d'ajouter une actualité
=end
class Admin::Operation
# Méthode qui permet d'arrêter un module d'apprentissage
#
# Arrêter un module consiste à :
#   - définir sa date de fin ended_at
#   - retirer son icetape courante (icetape_id)
#   - détruire le watcher de prochain paiement s'il existe
#   - supprimer l'icmodule de l'icarien (icmodule_id)
#   - marquer l'icarien inactif (bit 16 à 4)
# À la fin de l'opération, un mail est envoyé à l'icarien pour l'avertir.
#
def arret_module
  require_module('user/modules')
  self.admin_required
  # Envoyer le mail
  # Note : il faut commencer par là pour que le message trouve le nom du module
  owner.send_mail(subject:'Fin du module d’apprentissage', message:deserb('mails/arret_module/mail_owner', owner))
  # Marquer la date de fin du module et supprimer son étape courante
  dmodule = {ended_at: Time.now.to_i, icetape_id: nil}
  owner.icmodule.save(dmodule)
  # S'il y avait un paiement suivant, il faut le supprimer (et supprimer le watcher)
  if db_count('watchers', {wtype:'paiement_module', user_id: owner.id, objet_id: owner.icmodule.id}) > 0
    db_delete('watchers', {wtype:'paiement_module', user_id: owner.id, objet_id: owner.icmodule.id})
  end
  # L'icarien devient inactif
  owner.set_option(16, 4, false)
  downer = {options:owner.options, icmodule_id:nil}
  owner.save(downer)
  # Une actualité pour annoncer la fin du module
  # TODO
  # La confirmation finale
  message("le module de #{owner.pseudo} a été correctement arrêté.".freeze)
end #/ add_actualite
end #/Admin::Operation
