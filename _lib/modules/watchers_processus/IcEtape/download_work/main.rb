# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def download_work
    # Procéder au téléchargement des documents de travail de l'user
    path_folder = File.join(DOWNLOAD_FOLDER,'sent-work',"user-#{owner.id}")
    if File.exists?(path_folder)
      download(path_folder)
    else
      erreur "Désolé, mais le dossier #{path_folder} est introuvable.".freeze
    end
    owner.icetape.set(status:3)
    # Note : le watcher suivant est automatiquement créé
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
