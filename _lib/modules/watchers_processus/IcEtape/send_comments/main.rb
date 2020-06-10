# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def send_comments
    log('-> send_comments')
    log("param(:form_id): #{param(:form_id).inspect}")
    if param(:form_id) == 'send-comments-form'
      form = Form.new
      # Si le formulaire est conforme, on procède à l'upload des
      # document et on s'interromp en cas d'erreur
      if form.conform?
        proceed_sending_comments || raise(WatcherInterruption.new)
      end
    end
  end # / send_comments
  def contre_send_comments
    message "Je dois jouer le contre processus IcEtape/contre_send_comments"
  end # / contre_send_comments

  # Méthode qui procède à l'envoi des commentaires.
  # Cela consiste à :
  #   - récupérer les documents envoyés (associés aux documents enregistrés)
  #   - les mettre dans un dossier de 'sent-comments/user-<user id>'
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
        return erreur "Le fichier #{docfile_name}” est vide…"
      end
      # On l'enregistre dans le dossier
      path_file = File.join(path_dossier, docfile_name)
      file.open(path_file,'wb'){|f|f.write docfile_comments.read}
      nombre_commentaires += 1
    end

    unless nombre_commentaires > 0
      return erreur "Il faut transmettre au moins un document !".freeze
    end

    # On fait passer l'étape au statut suivant ()
    icetape.set(status: 4)
    # Le reste se fait automatiquement (mail à l'user, actualité, prochain
    # watcher)
    message "Le documents ont bien été enregistrés et #{owner.pseudo} a été averti#{fem(:e)}."
    return true
  end #/ proceed_sending_comments

end # /Watcher < ContainerClass
