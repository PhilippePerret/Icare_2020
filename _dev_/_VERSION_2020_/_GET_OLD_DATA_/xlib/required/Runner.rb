# encoding: UTF-8
# frozen_string_literal: true

class Runner
class << self
  def run
    clear_console
    puts "=== RÉCUPÉRATION ET TRANSFORMATION DES DONNÉES DISTANTES ===#{RC*3}".bleu
    reset_all if RESET_ALL
    reset
    run_all_scripts
  end #/ run

  def run_all_scripts
    SCRIPTS_LIST.each do |script_name|
      run_script(script_name)
    end
  end #/ run_all_scripts

  # Pour jouer le script de nom +script_name+
  # C'est forcément un script qui se trouve dans le dossier xlib/db_script
  def run_script(script_name)
    RunnerScript.new(script_name).proceed_if_necessary
  end #/ run_script

  # Pour initialiser le runner
  def reset

  end #/ reset

  # Pour tout réinitialiser, c'est-à-dire pour repartir du tout départ
  # Sinon, on ne fait que ce qu'il y a à faire.
  def reset_all
    run_script('empty_folder_final_tables')
    RunnerScript.reset_all
  end #/ reset_all

  def folder_script
    @folder_script ||= File.join(GOD_LIB_FOLDER,'db_scripts')
  end #/ folder_script
end # /<< self
end #/Runner
