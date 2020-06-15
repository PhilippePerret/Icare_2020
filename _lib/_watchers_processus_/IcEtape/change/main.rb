# encoding: UTF-8
class Watcher < ContainerClass
  def change
    message "Je dois jouer le processus IcEtape/change"
  end # / change
  def contre_change
    message "Je dois jouer le contre processus IcEtape/contre_change"
  end # / contre_change
end # /Watcher < ContainerClass
