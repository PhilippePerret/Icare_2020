# encoding: UTF-8
# frozen_string_literal: true

class Runner
class << self
  def run
    clear_console
    command = ARGV.first
    case command
    when NilClass
      puts "Il faut indiquer en argument le numéro du premier script à jouer suivi du numéro du dernier - ou rien pour jouer jusqu'au dernier.#{RC}(mettre 'help', '-h' ou '--help' en argument pour obtenir l'aide).".jaune
      return
    when 'drop_all', 'drop_all_table'
      # ON doit détruire toutes les tables distantes dans icare_db
      require_relative '../modules/drop_all_tables_online'
      return
    when 'help', 'aide', '--help', '-h'
      puts aide
      return
    when 'all'
      # Lancement de la procédure complète
      require_relative '../modules/recuperation_donnees'
      proceed_recuperation(number_first_script, number_last_script)
    else
      # Lancement d'un ou plusieurs scripts, hors intégrale
      from_script_number  = ARGV.shift
      to_script_number    = ARGV.shift || number_last_script
      require_relative '../modules/recuperation_donnees'
      proceed_recuperation(from_script_number, to_script_number)
    end
  end #/ run

  def number_first_script
    @number_first_script ||= SCRIPTS_LIST.first.split('_').first
  end #/ number_first_script
  def number_last_script
    @number_last_script ||= SCRIPTS_LIST.last.split('_').first
  end #/ number_last_script

  # Pour initialiser le runner
  def reset

  end #/ reset

  # Pour tout réinitialiser, c'est-à-dire pour repartir du tout départ
  # Sinon, on ne fait que ce qu'il y a à faire.
  def reset_all
    require_relative '../modules/empty_folder_final_tables'
    RunnerScript.reset_all
  end #/ reset_all

  def folder_script
    @folder_script ||= File.join(GOD_LIB_FOLDER,'db_scripts')
  end #/ folder_script

def aide
  script_base = File.dirname(__dir__).split('/').collect{|e| if e == 'Icare_2020' then @on = true;next end; if @on === true then e else nil end}.compact.join('/') + '/run.rb'
<<-TEXT
#{'=== AIDE DE LA RÉCUPÉRATION DES DONNÉES ==='.bleu}

Ce programme permet de passer les données à la version 2020 (version "COVID")
de l'atelier, dans une base unique.

#{'Lancement de la récupération'.bleu}
#{'============================'.bleu}

  Pour jouer l'intégralité de la suite
  ------------------------------------

    > ./#{script_base} all

    Cette commande va lancer la récupération complète des données distantes,
    et le peuplement complet de la nouvelle base 'icare_db'. Elle produit
    également le gel 'real-icare' qui met toutes les données en test.

  Pour jouer un script (qui correspond à une table)
  -------------------------------------------------
    > ./#{script_base} <num script> <num script>

    Par exemple :

    > ./#{script_base} 04 15
    # Pour jouer du script commençant par 04_ au script 15_

    > > ./#{script_base} 11 11
    # Pour ne jouer que le script commençant par 11_

    TIP 1 : voir ci-dessous la liste complète des scripts ou
    regarder dans le dossier `db_script`.

    TIP 2 : si on veut partir d'une base distante complètement vierge,
    on peut jouer :

      > #{script_base} drop_all

    #{'IMPORTANT'.rouge}
    #{'---------'.rouge}
    Si le premier script est choisi (#{number_first_script}), le programme
    procèdera à une initialisation complète avec destruction et récupération
    complète des données.

#{'Arguments'.bleu}
#{'---------'.bleu}

  help, -h, --help    Affiche cette aide.
  drop_all            ATTENTION : détruit toutes les tables de la base distante
                      icare_db
  <num script> <num script>
                      Méthode pour lancer la récupération des données, depuis
                      le premier script jusqu'au dernier.
                      Cf. ci-dessous la liste des scripts.

#{'Liste des scripts'.bleu}
#{'-----------------'.bleu}

#{TAB}#{Dir["#{folder_script}/*.rb"].sort.collect{|f|File.basename(f,File.extname(f))}.join(RC+TAB)}


TEXT
end #/ aide
end # /<< self
end #/Runner
