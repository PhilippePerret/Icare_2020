# encoding: UTF-8
require './_lib/required/__first/constants/paths'

# Erreur qui permet d'interrompre un watcher n'importe quand
class WatcherInterruption < StandardError; end

# Les constantes des processus de watchers
require File.join(PROCESSUS_WATCHERS_FOLDER,'_constants_')

ERRORS.merge!({
  processus_folder_unabled: "Impossible de requérir le dossier processus voulu.".freeze,
  owner_or_admin_required: "Hou %s… C’est pas bien du tout d’esssayer de jouer une notification qui ne vous appartient pas. Si vous recommencez, c’est la fessée.".freeze,
})
