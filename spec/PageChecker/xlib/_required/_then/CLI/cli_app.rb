# encoding: UTF-8
=begin

  Module fonctionnement avec le module cli.rb qui permet de définir, pour
  l'application propre, la conversion des diminutifs.

=end

class CLI
  # Raccourcis pour les commandes
  DIM_CMD_TO_REAL_CMD = {
    # 'prox'        => 'proximites',

  }

  # Option en diminutif et valeur réelle
  DIM_OPT_TO_REAL_OPT = {
    'o'   => 'online',
    'f'   => 'force',
    'h'   => 'help',
    'q'   => 'quiet',
    'v'   => 'verbose',
    'r'   => 'referer', # ajouter pour voir les référents des liens
  }
end #/CLI
