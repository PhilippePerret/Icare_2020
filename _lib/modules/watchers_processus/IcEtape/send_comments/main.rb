# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def send_comments
    if param(:form_id) == 'send-comments-forms'
      form = form.new
      proceed_sending_comments if form.valid?
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
  def proceed_sending_comments
    icetape.documents.each_with_index do |document, idx|
      # Ce document a-t-il un commentaire ?
    end
  end #/ proceed_sending_comments
end # /Watcher < ContainerClass
