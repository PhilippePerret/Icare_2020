# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def send_comments
    log('-> send_comments')
    log("param(:form_id): #{param(:form_id).inspect}")
    if param(:form_id) == 'send-comments-form'
      form = Form.new
      # Si le formulaire est conforme, on procède à l'upload des
      # document et on s'interrompt en cas d'erreur
      # On exécute aussi les extra-opérations de façon automatique
      if form.conform?
        proceed_sending_comments || raise(WatcherInterruption.new(nil))
      end
    end
  end # / send_comments

  # Méthode qui procède à l'envoi des commentaires
  # ----------------------------------------------
  # L'"envoi des commentaires" signifie qu'on récupère les fichiers fournis
  # dans le formulaire et qu'on les enregistre dans un dossier pour télécharge-
  # ment ultérieur par l'icarien.
  #
  # Cela consiste à :
  #   - récupérer les documents envoyés (associés aux documents enregistrés)
  #   - les mettre dans un dossier de 'sent-comments/user-<user id>'
  #   - définir que le commentaire du document existe
  #   - le reste (actualité, watcher suivant, se fait automatiquement)
  #
  # +return+  TRUE en cas de succès, NIL otherwise pour interrompre le
  #           watchter
  def proceed_sending_comments
    path_dossier = File.join(DOWNLOAD_FOLDER,'sent-comments',"user-#{owner.id}-#{icetape.id}")
    nombre_commentaires = 0
    # Boucler sur chaque document de l'étape
    icetape.documents.each_with_index do |document, idx|
      # Ce document a-t-il un commentaire ?
      docfile_comments = param("document-#{document.id}-comments".to_sym)
      next if docfile_comments.nil?
      docfile_name = docfile_comments.original_filename
      if docfile_comments.size == 0
        return erreur("Le fichier #{docfile_name}” est vide…".freeze)
      end
      # Un commentaire existe bien
      # On l'enregistre dans le dossier
      FileUtils.mkdir_p(path_dossier)
      path_file = File.join(path_dossier, docfile_name)
      File.open(path_file,'wb'){|f|f.write docfile_comments.read}
      document.set_option(8, 1, true)
      nombre_commentaires += 1
    end

    unless nombre_commentaires > 0
      return erreur("Il faut transmettre au moins un document !".freeze)
    end

    # Le reste se fait automatiquement (mail à l'user, actualité, prochain
    # watcher)
    message "Le documents ont bien été enregistrés et #{owner.pseudo} a été averti#{fem(:e)}."
    return true
  end #/ proceed_sending_comments

  def post_operation
    # On fait passer l'étape au statut suivant
    icetape.set(status: 4)
    # Ajouter un watcher pour le changement d'étape
    # de l'utilisateur
    owner.watchers.add('changement_etape', {vu_user:true, vu_admin:false, objet_id:objet_id})
  end #/ post_operation

end # /Watcher < ContainerClass
