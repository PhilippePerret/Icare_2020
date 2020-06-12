# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def qdd_sharing
    if param(:form_id)  # attention, on ne peut pas connaitre son nom (si ?)
                        # qui dépend de l'étape et il peut y avoir plusieurs
                        # formulaire de définition de partage (plusieurs étapes
                        # avec un vieille qui n'a pas été définie)
      form = Form.new
      if form.conform?
        message "Je dois définir le partage à partir de #{form.id}"
      end
    end
  end # / qdd_sharing
end # /Watcher < ContainerClass
