# encoding: UTF-8
require_modules(['form','user/modules','absmodules'])
html.add_js('./js/modules/form_with_files.js')

class HTML
  def titre
    # Note : le titre est dynamique en fonction de la chose à envoyer
    "#{RETOUR_BUREAU+Emoji.get('objets/parabole').page_title+ISPACE}#{MESSAGES["titre_#{param(:rid)}".to_sym]}".freeze
  end

  # Code à exécuter avant la construction de la page
  def exec
    unless user.actif?
      message("Vous n’êtes pas acti#{user.fem(:ve)}, vous ne pouvez donc pas envoyer de documents.".freeze)
      redirect_to(:bureau)
    end
    icarien_required
    if param(:form_id) == 'send-work-form'
      # On passe par ici lorsque l'icarien soumet le formulaire avec
      # ses documents (pour les transmettre)
      check_documents_and_save
    end
  end

  # Fabrication du body
  def build_body
    if param(:rid).nil?
      erreur(ERRORS[:nothing_to_send])
      redirect_to('bureau/home')
    else
      @body = deserb(param(:rid), self)
    end
  end

  # Méthode appelée lorsque l'on soumet les documents à envoyer
  def check_documents_and_save
    # S'il existe, on détruit le dossier qui doit contenir les document à
    # envoyer
    SentDocument.remove_user_folder(user, 'sent-work')

    # On boucle sur les cinq documents possibles
    sent_docs = []
    (1..5).each do |idoc|
      doc = param("document#{idoc}".to_sym)
      if doc # Un document a été fourni dans le champ
        sent_doc = SentDocument.new(idoc: idoc, docfile:doc, type:'sent-work', owner: user)
        if sent_doc.valid?
          sent_doc.traite
          sent_docs << sent_doc
        else
          erreur(ERRORS[:unable_document_treatment] % {name:sent_doc.original_filename, error:sent_doc.error})
          return false
        end
      end
    end

    if sent_docs.count > 0
      log("#{sent_docs.count} documents ok => Traitement")
      # Pour le mail à l'administrateur
      user.enregistre_documents_travail(sent_docs)
      Actualite.add('SENDWORK', user, MESSAGES[:actualite_send_work] % {pseudo:user.pseudo, numero:user.icetape.numero, module:user.icmodule.name})
      send_mails_annonce(sent_docs)
      # On enregistre son fichier d'information qui contient la note
      # et la date estimée de remise du travail
      sent_docs.each do |sentdoc| sentdoc.save_infos end
      remove_and_create_watchers
      param(:rid, 'sent_work_confirmation')
    else
      # Aucun document (valide) n'a été transmis, il faut redemander
      erreur(ERRORS[:sent_documents_required])
    end
  end #/ check_documents_and_save

  # Ce module particulier ne fonctionnant pas entièrement avec un watcher,
  # il faut les gérer "à la main", c'est-à-dire supprimer le watcher 'send_work'
  # et créer un nouveau watcher 'download_work'
  def remove_and_create_watchers
    user.watchers.remove(wtype:'send_work')
    user.watchers.add(wtype: 'download_work', objet_id:user.icetape.id)
  end #/ remove_and_create_watchers

  # Méthode qui se charge de l'envoi des mails à l'administrateur et
  # à l'icarien.
  # +sent_docs+   Liste des {SentDocument}, instance des documents envoyés.
  def send_mails_annonce sent_docs
    @plusieurs = sent_docs.count > 1
    require_module('mail')
    @documents_ids = []
    @documents_names = []
    @documents_ids_n_names = []
    @date_commentaires = formate_date(user.icetape.expected_comments, duree: true)
    sent_docs.each do |sdoc|
      @documents_ids << "##{sdoc.id}"
      @documents_ids_n_names << "#{sdoc.original_filename} (##{sdoc.id})"
      @documents_names << sdoc.original_filename
    end
    @documents_ids    = @documents_ids.join(VG)
    @documents_names  = @documents_names.join(VG)
    @documents_ids_n_names = @documents_ids_n_names.join(VG)

    Mail.send({
      subject: 'Envoi de documents de travail',
      from: user.mail,
      message: deserb('mail_admin', self)
    })
    s = @plusieurs ? 's' : ''
    Mail.send({
      subject: "Document#{s} de travail bien reçu#{s}".freeze,
      to: user.mail,
      message: deserb('mail_user', self)
      })
  end #/ send_mails_annonce

end #/HTML

# ---------------------------------------------------------------------
#   Extension de la classe système SentDocument pour checker
#   les documents de travail.
# ---------------------------------------------------------------------

class SentDocument
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
def save_infos
  note = param("note-document#{idoc}".to_sym)
  pathinfos = File.join(folder, "#{original_filename}-infos.json")
  docdata = {
    note: note,
    expected_comments: formate_date(user.icetape.expected_comments)
  }
  File.open(pathinfos,'wb'){|f| f.write docdata.to_json}
end #/ save_infos
def check
  if (note = param("note-document#{idoc}".to_sym).nil_if_empty)
    return true
  else
    # Si la note n'est pas définie, le document n'est pas valide
    self.error = ERRORS[:note_required]
    return false
  end
end #/ check

def init_icdocument
  now = Time.now.to_i
  options = '0'*16
  options[0] = '1'
  data_doc = {
    user_id: owner.id,
    icetape_id: user.icetape.id,
    original_name: original_filename,
    time_original: now,
    options: options
  }
  log(" ---- data_doc: #{data_doc.inspect}")

  # DEBUG
  log("CREATION DOCUMENT AVEC DONNÉES : ")
  log(data_doc.inspect)
  # return

  @id = db_compose_insert('icdocuments', data_doc) # => ID
end #/ init_icdocument

# Méthode qui estime le temps qui sera nécessaire pour corriger
# ce document.
# Note : c'est une valeur très estimative
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

  def enregistre_documents_travail(sentdocs)

    # Pour savoir combien il faudra de temps pour corriger les documents
    # On compte toujours un jour et demi au départ
    duree_totale_commentaire = 1.5 * JOUR

    # On instancie autant d'icdocument qu'il y a de documents
    sentdocs.each do |sentdoc|
      icdocument = sentdoc.init_icdocument
      duree_totale_commentaire += sentdoc.duree_commentaire
    end

    # # DEBUG
    # log("La durée totale de commentaire serait : #{duree_totale_commentaire}")
    # log("Il faudrait donc les terminer pour : #{formate_date(Time.now.to_i + duree_totale_commentaire)}")

    # Les nouvelles data pour l'étape
    log("--- DATA ÉTAPE")
    data_etape = {
      expected_comments: Time.now.to_i + duree_totale_commentaire,
      status: 1
    }
    icetape.set(data_etape)

  end #/ enregistre_documents_travail
end #/User
