# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def qdd_sharing
    if param(:form_id) == "sharing-form-etape-#{icetape.id}"
      form = Form.new
      if form.conform?
        definir_partage_des_documents(form)
      else
        raise WatcherInterruption.new
      end
    end
  end # / qdd_sharing

  # Appelée quand l'icarien soumet le formulaire
  def definir_partage_des_documents(form)
    icetape.documents.each do |document|
      opts = document.options
      opts[4] = '1' # partage défini
      opts[1] = param("partage-#{document.id}-original") # 1 ou 2
      opts[5] = '1' # fin de cycle complet
      comments_shared = nil
      if document.has_comments?
        opts[12] = '1'
        opts[9] = param("partage-#{document.id}-comments") # 1 ou 2
        opts[13] = '1'
      end
      document.save(options: opts)
    end
    # On marque la fin du cycle de l'étape
    icetape.save(status: 7)
    message "Merci pour la définition de ce partage. Vous pourrez le rectifier à tout moment en rejoignant le #{quai_des_docs}.".freeze
  end #/ definir_partage_des_documents
end # /Watcher < ContainerClass
