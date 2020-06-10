# encoding: UTF-8
MESSAGES.merge!({
  bonne_lecture: "Bonne lecture à vous, %s ! Et n'oubliez pas que si vous avez la moindre question, Phil est là pour vous répondre".freeze
  })
ERRORS.merge!({
  unfound_folder_comments: 'Le dossier des commentaires est introuvable… Vous devez l’avoir déjà chargé.'.freeze
})
require_module('icmodules')
class Watcher < ContainerClass
  def download_comments
    path_dossier = File.join(DOWNLOAD_FOLDER,'sent-comments',"user-#{owner.id}-#{icetape.id}")
    if File.exists?(path_dossier)
      download_from_watcher(path_dossier)
    else
      erreur ERRORS[:unfound_folder_comments]
    end
  end # / download_comments
  def contre_download_comments
    message "Je dois jouer le contre processus IcEtape/contre_download_comments"
  end # / contre_download_comments
end # /Watcher < ContainerClass
