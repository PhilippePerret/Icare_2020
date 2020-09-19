# encoding: UTF-8
require_module('qdd')
class Watcher < ContainerClass
  def cotes_n_comments
    message("Je passe par ici")
    if param(:form_id) == "cote-n-comments-#{objet_id}"
      form = Form.new
      enregistre_cote_et_commentaire if form.conform?
    end
  end # / cotes_n_comments

  # Méthode qui enregistre la cote et le commentaire
  def enregistre_cote_et_commentaire
    raise(WatcherInterruption.new("J'ai interrompu"))
  end #/ enregistre_cote_et_commentaire
end # /Watcher < ContainerClass
