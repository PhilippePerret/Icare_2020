# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def qdd_depot
    message "Je dois jouer le processus IcEtape/qdd_depot"
  end # / qdd_depot
  def contre_qdd_depot
    message "Je dois jouer le contre processus IcEtape/contre_qdd_depot"
  end # / contre_qdd_depot
end # /Watcher < ContainerClass

class IcDocument < ContainerClass
  # La méthode retourne true si le document a des commentaires
  def has_comments?
    get_option(8) == 1
  end #/ has_comments?
end #/IcModule < ContainerClass
