# encoding: UTF-8
# frozen_string_literal: true
class Admin::Operation
def inject_document
  msg = []
  require './_lib/_pages_/bureau/sender/constants.rb'
  require_module('user/modules')
  require_module('watchers')
  msg << "*** Injection de documents envoyés par mail ***"

  pseudo    = owner.pseudo
  icmodule  = owner.icmodule
  icetape   = owner.icetape

  if icetape.status > 3
    raise "Le statut de l'étape est supérieur à 2, je ne peux pas ajouter ce document."
  end

  medium_value.to_s != "" || raise("Il faut indiquer les noms des documents !")

  document_names = medium_value.split(';')
  plusieurs = document_names.count > 1
  s = plusieurs ? 's' : ''
  if simulation?
    msg << "Les document#{s} #{document_names.join(', ')} doi#{'ven' if plusieurs}t être ajouté#{s} à #{pseudo} pour son module ##{icmodule.id}"
  else
    msg << "Document#{s} à ajouter : #{document_names.join(', ')}"
  end

  # Données pour l'étape
  # --------------------
  data_etape = {
    expected_comments: Time.now.to_i + 7 * JOUR,
    status: 3
  }
  if simulation?
    msg << "Données de l'étape courante ##{icetape.id} mises à #{data_etape}"
  else
    icetape.set(data_etape)
    msg << "Enregistrement des données de l'Ic-étape ##{icetape.id}"
  end

  # On crée des instance IcDocument pour chaque document
  document_names.each do |doc_name|
    if simulation?
      msg << "Création de l'instance IcDocument de nom : #{doc_name.inspect}"
    else
      doc_id = create_icdocument(owner, doc_name)
      # Note : dans la nouvelle version, on n'a plus besoin de l'identifiant
      # de l'icDocument pour l'icetape, puisqu'elle n'est plus enregistrée
      # avec l'identifiant des documents
    end
  end

  # Watcher pour pouvoir commenter les documents
  if simulation?
    msg << "Le Watcher 'icetape#send_work' sera détruit et remplacé par un watcher 'send_comments'."
  else
    owner.watchers.remove(wtype:'send_work')
    owner.watchers.add(wtype: 'send_comments', objet_id: icetape.id)
    msg << "Watcher 'send_work' remplacé par 'send_comments'"
  end

  # Actualité pour annoncer l'envoi DES documents
  msg_actu = MESSAGES[:actualite_send_work] % {pseudo:owner.pseudo, numero:icetape.numero, module:icmodule.name}
  if simulation?
    msg << "Création d'une actualité de message #{msg_actu.inspect}"
  else
    Actualite.add('SENDWORK', owner, msg_actu)
    msg << "Actualité produite avec le message #{msg_actu.inspect}"
  end

  msg << "=== Opération exécutée avec succès ===" if not simulation?

  msg = msg.collect { |m| "[SIM] #{m}" } if simulation?

  msg = msg.join("<br/>")
  Ajax << {message: msg}
rescue Exception => e
  log(e)
  Ajax << {error: e.message}
end

# On crée l'instance icdocument pour le document
# Et on retourne son identifiant
def create_icdocument(u, name)
  now = Time.now.to_i
  options = '0'*16
  options[0] = '1'
  data_doc = {
    user_id: u.id,
    icetape_id: u.icetape.id,
    original_name: name,
    time_original: now,
    options: options
  }
  doc_id = db_compose_insert('icdocuments', data_doc) # => ID

  return doc_id
end #/ init_icdocument

end #/Admin::Operation
