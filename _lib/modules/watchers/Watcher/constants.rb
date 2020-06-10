# encoding: UTF-8

# Erreur qui permet d'interrompre un watcher n'importe quand
class WatcherInterruption < StandardError; end

PROCESSUS_WATCHERS_FOLDER = File.join(MODULES_FOLDER,'watchers_processus')

# Les constantes des processus de watchers
require_relative '../../watchers_processus/_constants_'
