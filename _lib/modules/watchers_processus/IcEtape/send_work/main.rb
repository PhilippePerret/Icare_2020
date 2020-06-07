# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def send_work
    message "Je dois jouer le processus IcEtape/send_work"
  end # / send_work
  def contre_send_work
    message "Je dois jouer le contre processus IcEtape/contre_send_work"
  end # / contre_send_work
end # /Watcher < ContainerClass
