# encoding: UTF-8
=begin
  Watcher IcModule.start
=end
require_module('absmodules')
require_module('icmodules')
class Watcher < ContainerClass
  def start
    message "Je dois démarrer le module."
  end #/ start
end #/IcModule
