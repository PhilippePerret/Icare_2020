# encoding: UTF-8
# frozen_string_literal: true
require_relative './constants'

require_module('icmodules')
class Watcher < ContainerClass
  def qdd_depot
    if param(:form_id) == "qdd-depot-form-etape-#{icetape.id}"
      if Form.new.conform?
        proceder_au_depot_des_documents()
        message(MESSAGES[:qdd_confirm_depot])
      else
        raise WatcherInterruption.new
      end
    end
  end # / qdd_depot

  def proceder_au_depot_des_documents()
    require_module('ticket')
    folder_depot = File.join(QDD_FOLDER, icetape.icmodule.absmodule.id.to_s)
    documents_ids = [] # pour les tickets, plus bas
    icetape.documents.each do |document|
      opts = document.options
      log("Nom du document pour dépôt : #{File.basename(document.qdd_path(:original))}")
      # Déposer les documents bien nommés sur le QDD
      docfile_o = param("document-#{document.id}-original")
      docfile_o || raise(ERRORS[:doc_qdd_required] % ['original', document.name])
      docfile_o.size > 0 || raise(ERRORS[:doc_qdd_empty] % ['original', document.name])
      if document.has_comments?
        docfile_c = param("document-#{document.id}-comments")
        docfile_c || raise(ERRORS[:doc_qdd_required] % ['commentaires', document.name])
        docfile_c.size > 0 || raise(ERRORS[:doc_qdd_empty] % ['commentaires', document.name])
      end
      opath = document.path_qdd(:original)
      FileUtils.mkdir_p(File.dirname(opath)) # on s'assure que le dossier existe
      File.open(opath,'wb'){|f| f.write(docfile_o.read)}
      opts[3] = '1'
      if document.has_comments?
        File.open(document.path_qdd(:comments),'wb'){|f| f.write(docfile_c.read)}
        opts[11] = '1'
      end
      document.save(options: opts)
      documents_ids << document.id
    end

    # Passer au status d'étape suivant
    icetape.save(status: 6)

    # Les tickets qui doivent servir à l'user, dans son mail,
    # pour valider ses documents
    @ticket_share_all = Ticket.create(user_id: owner.id, code:"require_module('icdocuments');IcDocument.share(#{documents_ids.join(VG)})")
    @ticket_share_nothing = Ticket.create(user_id: owner.id, code:"require_module('icdocuments');IcDocument.unshare(#{documents_ids.join(VG)})")
    @tickets = {} # tickets par document
    icetape.documents.each do |doc|
      docid = doc.id
      @tickets.merge!(docid => {
        name: doc.name,
        share: Ticket.create(user_id:owner.id, code:"require_module('icdocuments');IcDocument.share(#{docid})"),
        unshare: Ticket.create(user_id:owner.id, code:"require_module('icdocuments');IcDocument.unshare(#{docid})")
      })
    end
  rescue Exception => e
    log(e)
    raise WatcherInterruption.new(e.message)
  end #/ proceder_au_depot_des_documents
end # /Watcher < ContainerClass
