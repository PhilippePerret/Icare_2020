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

  #{'icare check[ <what>][ <id>]'.jaune}

      Pour procéder à des checks de l'atelier, à commencer par les données
      des modules d'apprentissage des icariens.

      <what>
      ------
        all         Tout checker, les users, les modules, les étapes, les
                    documents.
        user[s]     Checker les users. Si un identifiant est ajouté, on checke
                    seulement cet user-là.
        module[s]   Checker les modules ou le module dont l'identifiant est
                    fourni. Ça comprend le check des étapes et des documents.

      Options
      -------
        -l/--local    Faire le check sur les données locales (par défaut c'est
                      sur les données distantes)
        -v/--verbose  Afficher tous les messages
        -i/--infos    Afficher une seule fois les choses checkées et mettre la
                      formule réduite pour le reste.
        -r/--reparer  Pour réparer les erreurs rencontrées
        -s/--simuler  Pour seulement simuler les réparations, mais ne pas les
                      faire.
        -u/--interactive  Pour que la commande demande le détail des options
                      ci-dessus de façon interactive. Note : on passe aussi
                      dans ce mode quand on ne définit pas d'objet d'étude (pas
                      de 'module', 'user', etc.)

  LISTE DES COMMANDES
  -------------------
  - #{liste_commandes.join("\n  - ")}

=======================================================================


BASH
