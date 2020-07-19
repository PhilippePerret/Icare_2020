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

  #{'icare feed[ <what>]'.jaune}

      Pour "nourrir" la base de données icare_test avec des
      valeurs appropriées.


  LISTE DES COMMANDES
  -------------------
  - #{liste_commandes.join("\n  - ")}

=======================================================================


BASH
