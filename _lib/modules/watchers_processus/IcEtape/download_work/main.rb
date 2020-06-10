# encoding: UTF-8
require_module('icmodules')
require_module('user/modules')
THREADS = []

=begin
  - je recharge la page, avec un truc dans l'url qui dit que c'est pour un download
  - => la page est actualisée
  - le truc dans l'url fait qu'on écrit un code pour appeler le ticket qui
    doit procéder au download avec window.location="<route>?tik=<ticket>" avec
    un timeout assez court
  - => après ce timeout, la location est changé, le ticket est joué et
    déclenche un download, ce qui ne change pas la page actuelle
=end

class Watcher < ContainerClass
  def download_work
    # Procéder au téléchargement des documents de travail de l'user
    path_folder = File.join(DOWNLOAD_FOLDER,'sent-work',"user-#{owner.id}")
    if File.exists?(path_folder)
      unless TESTS
        download_from_watcher(path_folder)
      else
        # Quand on est en mode test
        # TODO NOTE il faudra peut-être détuire le dossier "à la main"
        # comme le ferait le download suivant.
        redirect_to(route.to_s)
      end
    else
      erreur "Désolé, mais le dossier #{path_folder} est introuvable.".freeze
    end
    owner.icetape.set(status:3)
    # Note : le watcher suivant est automatiquement créé
  end # / download_work
end # /Watcher < ContainerClass
