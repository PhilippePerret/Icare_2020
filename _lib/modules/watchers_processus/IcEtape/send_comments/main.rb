# encoding: UTF-8
require_module('icmodules')
class Watcher < ContainerClass
  def send_comments
    message "Je dois jouer le processus IcEtape/send_comments"
  end # / send_comments
  def contre_send_comments
    message "Je dois jouer le contre processus IcEtape/contre_send_comments"
  end # / contre_send_comments
end # /Watcher < ContainerClass
