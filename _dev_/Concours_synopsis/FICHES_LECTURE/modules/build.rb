# encoding: UTF-8
# frozen_string_literal: true
class FLFactory
class << self
  # = main =
  #
  # Méthode principale procédant à la fabrication des fiches de lecture
  def proceed_build_fiches_lecture
    rapatriement_des_fiches_evaluations
    evaluations_des_synopsis
    production_des_fiches
  end #/ proceed_build_fiches_lecture

  def rapatriement_des_fiches_evaluations
    require './_dev_/CLI/lib/commands/concours/download'
    suivi("\n== Rapatriement des fiches d'évaluations ==", :bleu)
    suivi("== Dossier de réception : #{data_folder}", :bleu)
    if mode_tests?
      suivi("   MODE TESTS => Pas de rapatriement")
    else
      # On n'est pas en mode test il faut ramener les évaluations des
      # synopsis.
      # SSH_ICARE_SERVER

      # IcareCLI.files_per_annee
      # puts "DATA_CONCOURS = #{DATA_CONCOURS.inspect}"

      # cmd = "scp -C -r -p -q #{SSH_ICARE_SERVER}:www/_lib/data/concours/**/evaluation-*.json #{mkdir(data_folder)}"
      cmd = "rsync -avm --include='*/' --include='evaluation-*.json' --exclude='*' #{SSH_ICARE_SERVER}:www/_lib/data/concours/ #{mkdir(data_folder)}"
      # Options :
      #   a : archiver => récursif
      #   m : prune empty dirs (ne les copie pas)
      #   v : verbose
      if false
        puts "Command RSync: #{cmd.inspect}"
        res = `#{cmd} 2>&1`
        puts "Retour de rsync : #{res.gsub(/\\n/,"\n")}"
      end

      # DATA_CONCOURS.merge!(data_concurrents)
      puts "DATA_CONCOURS: #{data_concurrents.pretty_inspect}"
    end
  end #/ rapatriement_des_fiches_evaluations

  def evaluations_des_synopsis
    suivi("\n== Évaluation des synopsis ==", :bleu)

  end #/ evaluations_des_synopsis

  def production_des_fiches
    suivi("\n== Production des fiches de lecture ==", :bleu)

  end #/ production_des_fiches

end # /<< self
end #/FLFactory
