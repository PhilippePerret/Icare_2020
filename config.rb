# encoding: UTF-8
=begin
  Fichier de configuration de l'atelier Icare

  Note : ce fichier est appelé APRÈS le fichier des constantes.

=end

# Conservation du log
# -------------------
# Constante permettant de définir si le log (journal.log) doit être
# réinitialiser à chaque fois, ou conserver.
# RESET_LOG = OFFLINE && true # => En online, il est toujours conservé
RESET_LOG = false # en mode test, pour le moment, on met comme ça

# Outils développements de bas de page
# ------------------------------------
# Pour définir si les outils de développement qui se trouve tout en bas
# de la page, qui permettent par exemple de lancer des processus rapidement,
# doivent être affichés.
# SHOW_DEVELOPPEMENT_TOOLS = OFFLINE && true
SHOW_DEVELOPPEMENT_TOOLS = false # pour ne jamais le montrer

# Mode sandbox
# ------------
# Pour définir que le site doit fonctionner en mode bac à sable, notamment
# en utilisant la table icare_test plutôt que icare
unless defined?(SANDBOX)
  SANDBOX = true
end

# Affichage du debug
# -------------------------
# Pour afficher le débug en bas de page (il faut être en offline)
# SHOW_DEBUG = false # pour ne jamais le montrer
SHOW_DEBUG = OFFLINE && true # pour l'afficher en offline
# SHOW_DEBUG = true # pour l'afficher dans tous les cas
