# encoding: UTF-8
require_module('icmodules')
require_module('user/modules')
THREADS = []

class Watcher < ContainerClass
  def download_work
    # Procéder au téléchargement des documents de travail de l'user
    path_folder = File.join(DOWNLOAD_FOLDER,'sent-work',"user-#{owner.id}")
    if File.exists?(path_folder)
      THREADS << Thread.new { download(path_folder)   }
      THREADS << Thread.new { redirect_to(route.to_s) }
    else
      erreur "Désolé, mais le dossier #{path_folder} est introuvable.".freeze
    end
    owner.icetape.set(status:3)
    # Note : le watcher suivant est automatiquement créé
  end # / download_work
end # /Watcher < ContainerClass
