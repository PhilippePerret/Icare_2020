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

  LISTE DES COMMANDES
  -------------------
  - #{liste_commandes.join("\n  - ")}

=======================================================================


BASH
