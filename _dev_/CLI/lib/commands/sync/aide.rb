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

#{'Noter que les filtrages ne s’applique pas au traitement d’un'.rouge}
#{'unique fichier'.rouge}.
Par exemple, les fichiers 'index.rb' et '.htaccess' sont exclus des
synchronisation, mais si on joue #{'icare sync index.rb'.jaune}, alors ce fichier
sera synchronisé.

Pour voir tous les éléments ignorés et les définir de façon définitive,
jouer la commande (qui ouvre le fichier '.syncignore' qui se situe dans
le dossier 'sync') :

  #{'icare sync ignore'.jaune}

On peut ponctuellement ignorer des fichiers ou des dossiers avec l'option :

  #{'--ignore=...'.jaune}

On met en argument de cette fonction les paths des fichiers à exclure,
séparés par des virgules. Par exemple :

  #{'--ignore=.htaccess,index.rb'.jaune}

  TEXT
end #/ aide
end # /<< self
end #/IcareCLI
