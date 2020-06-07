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

# Le temps approximatif pour commenter une page de document
NOMBRE_JOURS_PER_PAGE = 1.55

MOTS_PER_PAGE = 450

JOUR = 3600 * 24

RATIO_MOTS_PER_DOCTYPE = {
  '.odt'  => 0.097,
  '.rtf'  => 0.107,
  '.doc'  => 0.02,
  '.docx' => 0.162,
  'any'   => 0.097
}

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
  log(" ---- data_doc: #{data_doc.inspect}")
  db_compose_insert('icdocuments', data)
  request = "INSERT INTO icdocuments (#{columns}) VALUES (#{interro})"
  db_exec(request, valeurs)
  return db_last_id
end #/ init_icdocument

# Méthode qui calcule le temps qui sera nécessaire pour corriger
# ce document.
def duree_commentaire
  size = docfile.size
  extension = File.extname(original_filename)
  ratio = RATIO_MOTS_PER_DOCTYPE[extension]
  if ratio.nil?
    if ['.md','.txt','.text','.mmd'].include?(extension)
      # On lit le nombre de mots tels quels
      nombre_mots = content.split(' ').count
    else
      # Sinon, on prend la taille est on estime en moyenne des autres
      ratio = RATIO_MOTS_PER_DOCTYPE['any']
      nombre_mots = size * ratio
    end
  else
    # Le ratio est connu
    nombre_mots = size * ratio
  end

  nombre_pages = (nombre_mots.to_f / MOTS_PER_PAGE).round(2)

  return (nombre_pages * NOMBRE_JOURS_PER_PAGE * JOUR)
end #/ duree_commentaire

end #/SentDocument


class User
  # Enregistrement des documents transmis et initialisation d'un watcher pour
  # pouvoir suivre leur parcours.
  # Note : les documents ont déjà été placés dans le dossier de l'user
  duree_totale_commentaire = 1.5 * JOUR

  def enregistre_documents_travail(sentdocs)

    # On instancie autant d'icdocument qu'il y a de documents
    sentdocs.each do |sentdoc|
      icdocument = sentdoc.init_icdocument
      duree_totale_commentaire += icdocument.duree_commentaire
    end

    # Les nouvelles data pour l'étape
    log("--- Enregistrement data de l'étape")
    data_etape = {
      expected_comments: Time.now.to_i + duree_totale_commentaire
    }
    icetape.set(data_etape)
    log("--- Commentaires attendus pour : #{formate_date(data_etape[:expected_comments])}")

    # Le watcher pour l'étape
    log("--- Watcher pour l'étape")
    dwatcher_etape = {objet_id: icetape.id, expected_at: data_etape[:expected_comments]}
    watchers.add('getting_work', dwatcher_etape)

    # Note : on n'enregistre plus les documents dans l'étape
  end #/ enregistre_documents_travail
end #/User
