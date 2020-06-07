# encoding: UTF-8
require_module('form')
require_module('user/modules')
class HTML
  def titre
    # Note : le titre est dynamique en fonction de la chose à envoyer
    "#{RETOUR_BUREAU}📡 #{MESSAGES["titre_#{param(:rid)}".to_sym]}".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    if param(:form_id) == 'send-work-form'
      check_documents_and_save
    end
  end
  # Fabrication du body
  def build_body
    @body = deserb(param(:rid), self)
  end

  # Méthode appelée lorsque l'on soumet les documents à envoyer
  def check_documents_and_save
    debug("-> check_documents_and_save")
    # On détruit le dossier s'il existe
    folder = File.join(DOWNLOAD_FOLDER,'sent-work',"user-#{user.id}")
    FileUtils.rm_rf(folder) if File.exists?(folder)
    sent_docs = []
    (1..5).each do |idoc|
      doc = param("document#{idoc}".to_sym)
      doc && sent_docs << SentDocument.new(idoc: idoc, docfile:doc, type:'sent-work', owner: user).traite
    end

    if sent_docs.count > 0
      user.enregistre_documents_travail(docs)
    else
      # Aucun document n'a été transmis, il faut redemander
      erreur ERRORS[:sent_documents_required]
    end
  end #/ check_documents_and_save

  # Un document qui doit être traité car il est défini
  def traite_document(idoc, docfile)
    debug("Document #{idoc} : #{docfile.original_filename}")
  end #/ traite_document
end #/HTML

class SentDocument
def check
  debug "Je dois checker le document"
  if (note = param("note-document#{idoc}".to_sym))
    pathnote = File.join(folder, "#{original_filename}-note.txt")
    File.open(pathnote,'wb'){|f| f.write note}
  else
    return false
  end
  return true
end #/ check

def init_icdocument
  now = Time.now.to_i
  data_doc = {
    user_id: owner.id,
    icetape_id: user.icetape.id,
    original_name: original_filename,
    time_original: now,
    created_at: now,
    updated_at: now
  }
  db_compose_insert('icdocuments', data)
  request = "INSERT INTO icdocuments (#{columns}) VALUES (#{interro})"
  db_exec(request, valeurs)
  return db_last_id
end #/ init_icdocument
end #/SentDocument


class User
  # Enregistrement des documents transmis et initialisation d'un watcher pour
  # pouvoir suivre leur parcours.
  # Note : les documents ont déjà été placés dans le dossier de l'user
  def enregistre_documents_travail(sentdocs)
    # On instancie autant d'icdocument qu'il y a de document
    # TODO
    # On crée un watcher pour chacun d'entre eux (mais attention, si on
    # fait ça, on retombe dans le problème d'avoir autant de watchers que de
    # document. Ça simplifie la programmation, mais ça complique les
    # manipulations)
    # Il vaudrait mieux travailler au niveau de l'étape :
    # Un seul watcher de chargement des documents. On distinguera des watchers
    # peut-être seulement au moment au dépôt sur le quai des docs
    sentdocs.each do |sentdoc|
      icdocument = sentdoc.init_icdocument
    end
  end #/ enregistre_documents_travail
end #/User
