# encoding: UTF-8
# frozen_string_literal: true

# Tout le travail sur les bases se fait en local
ONLINE = false

class Runner
class << self
  def proceed_recuperation(from_script_number, to_script_number)
    puts "=== RÉCUPÉRATION ET TRANSFORMATION DES DONNÉES DISTANTES ===".bleu
    puts "=".bleu
    puts "=   Exécution du script #{from_script_number} au script #{to_script_number}.#{RC*2}".bleu

    if from_script_number == number_first_script
      reset_all if RESET_ALL
      reset
    end

    scripts = []
    from_idx  = nil
    to_idx    = nil
    SCRIPTS_LIST.each_with_index do |scp_name, idx|
      if scp_name.start_with?(from_script_number)
        from_idx = idx
      end
      if scp_name.start_with?(to_script_number)
        to_idx = idx
        break
      end
    end

    if from_idx.nil? || to_idx.nil?
      return failure("Impossible de savoir quels scripts jouer…")
    end

    # Script à jouer
    run_all_scripts(SCRIPTS_LIST[from_idx..to_idx])
    # Faut-il exporter et uploader les tables ?
    if to_script_number.to_i < 90
      TableGetter.export_tables
      TableGetter.upload_tables
    end
  end #/ proceed_recuperation


  def run_all_scripts(scripts)
    scripts.each do |script_name|
      run_script(script_name)
    end
  end #/ run_all_scripts


  # Pour jouer le script de nom +script_name+
  # C'est forcément un script qui se trouve dans le dossier xlib/db_script
  def run_script(script_name)
    RunnerScript.new(script_name).proceed_if_necessary
  end #/ run_script

end # /<< self
end #/Runner
