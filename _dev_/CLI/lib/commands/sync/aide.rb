# encoding: UTF-8
# frozen_string_literal: true
class IcareCLI
class << self
def show_aide
  puts aide
end #/ aide
def aide
  clear
  <<-TEXT
=== Aide pour la synchronisation ===

* Pour vérifier la synchronisation d'un fichier :

  #{'icare sync ./path/to/file.ext ./path/to/other.ext ./to/folder (*)'.jaune}

  (*) Dossiers ou fichier. Tous les chemins en point sont relatifs à la
      base du site.

Ajouter l'option #{'--sync'.jaune} pour procéder à la synchronisation ou
lancer la synchronisation dans un second temps à l'aide de :

  #{'icare sync --sync'.jaune}

Pour détruire les fichiers solitaires sur le site distant (#{'ATTENTION !'.rouge}),
il faut ajouter l'option :

  #{'--remove-distants-seuls'.jaune}

== Filtrage des éléments ==

  TEXT
end #/ aide
end # /<< self
end #/IcareCLI
