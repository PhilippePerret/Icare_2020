# encoding: UTF-8

# Erreur qui permet d'interrompre un watcher n'importe quand
class WatcherInterruption < StandardError; end

# Les constantes des processus de watchers
require File.join(PROCESSUS_WATCHERS_FOLDER,'_constants_')
