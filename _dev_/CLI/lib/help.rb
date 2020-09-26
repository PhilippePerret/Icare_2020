# encoding: UTF-8
liste_commandes = Dir["#{COMMANDS_FOLDER}/*.rb"].collect{|m|File.basename(m,File.extname(m))}
AIDE = <<-BASH

=======================================================================
#{'=== AIDE DE LA COMMANDE icare ==='.bleu}

  #{'icare help'.jaune}

      Pour obtenir cette aide.

  #{'icare degel[ <gel_name>]'.jaune}

      Pour dégeler un gel (un état de l'atelier particulier)
      Ne pas mettre d'argument pour voir la liste de tous les gels.

  #{'icare read[ <what>]'.jaune}

      Pour lire le journal.log, le traceur, le manuel, etc.

  #{'icare goto la/route'.jaune}

      Pour rejoindre la route voulue dans un navigateur. Ajouter l'option
      -o/--online pour la rejoindre sur le site distant.

  #{'icare check[ <what>]'.jaune}

      Pour procéder à des checks de l'atelier, à commencer par les données
      des modules d'apprentissage des icariens.
      Options
      -------
        -l/--local    Faire le check sur les données locales (par défaut c'est
                      sur les données distantes)
        -v/--verbose  Afficher tous les messages
        -i/--infos    Afficher une seule fois les choses checkées et mettre la
                      formule réduite pour le reste.

  LISTE DES COMMANDES
  -------------------
  - #{liste_commandes.join("\n  - ")}

=======================================================================


BASH
