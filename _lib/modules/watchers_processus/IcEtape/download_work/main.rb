# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def download_work
    message "Téléchargement des document (à implémenter)"
  end # / download_work
end # /Watcher < ContainerClass

class IcEtape
  # Retourne la liste des instances IcDocuments de l'étape
  def documents
    @documents ||= begin
      request = "SELECT * FROM icdocuments WHERE icetape_id = #{id}".freeze
      db_exec(request).collect do |ddoc|
        IcDocument.instantiate(ddoc)
      end
    end
  end #/ documents
end #/IcEtape
