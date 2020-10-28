# encoding: UTF-8
liste_commandes = Dir["#{COMMANDS_FOLDER}/*.rb"].collect{|m|File.basename(m,File.extname(m))}
AIDE = <<-BASH

=======================================================================
#{'=== AIDE DE LA COMMANDE icare ==='.bleu}

  #{'icare help'.jaune}

      Pour obtenir cette aide.

  #{'icare test'.jaune}

      Pour faire un test minimal du fonctionnement du site en online,
      après une modification du code par exemple.

      Paramètres
      ----------
        Un premier paramètre peut déterminer la seule page à vérifier
        Note : elle doit être définie dans le fichier test/data_urls.yaml
        Exemple :   #{'icare test user/login'.jaune}

      Options
      -------
        -i/--infos  Par défaut, la page ne s'affiche pas (mode headless). En
                    ajoutant cette option, on peut la voir. En général, on
                    rajoute une ligne '- :doit: sleep 20' pour avoir le temps
                    de voir la page (et de chercher le tag).

      Pour ajouter une nouvelle page, voir le fichier :
      commands/test/data_urls.yaml où tout est expliqué.

  #{'icare degel[ <gel_name>]'.jaune}

      Pour dégeler un gel (un état de l'atelier particulier)
      Ne pas mettre d'argument pour voir la liste de tous les gels.

  #{'icare infos <what> <id>'}

      Retourne les informations les plus complètes possibles sur l'objet
      de type <what> (qui peut être 'user','icarien', 'module', 'etape',
      'document') d'identifiant <id>.
      Note : pour le moment, les informations sont toujours récupérées sur
      le site distant.

  #{'icare read[ <what>]'.jaune}

      Pour lire le journal.log, le traceur, le manuel, etc.

  #{'icare concours[ <cmd>]'.jaune}

      Gestion du concours de synopsis. Utiliser la sous-commande 'help'
      pour avoir toutes les informations

  #{'icare cron[ <command>]'.jaune}

      Pour interagir avec le cron distant (ou pas).
      Jouer simplement 'icare cron' pour avoir les propositions.

  #{'icare goto la/route'.jaune}

      Pour rejoindre la route voulue dans un navigateur. Ajouter l'option
      -o/--online pour la rejoindre sur le site distant.

  #{'icare check[ <what>][ <id>]'.jaune}

      Pour procéder à des checks de l'atelier, à commencer par les données
      des modules d'apprentissage des icariens.

      Note : utiliser la commande 'infos' pour obtenir des informations pré-
      cises sur un élément (cf. plus haut).

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

      Autres options
      --------------

        On peut limiter le nombre d'objets checkés avec la variable d'envi-
        ronnement 'MAX_CHECKS' :

        > MAX_CHECKS=20 icare check etapes -s

        La commande ci-dessus va checker les 20 premières étapes en simulant
        les corrections qui seront faites.

  LISTE DES COMMANDES
  -------------------
  - #{liste_commandes.join("\n  - ")}

=======================================================================


BASH
