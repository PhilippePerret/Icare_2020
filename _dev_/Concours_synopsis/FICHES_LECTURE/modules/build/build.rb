# encoding: UTF-8
# frozen_string_literal: true

# La class Evaluation qui va permettre d'obtenir les notes
require './_lib/_pages_/concours/xmodules/synopsis/Evaluation'

class FLFactory
class << self
  attr_reader :projets_valides

  # = main =
  #
  # Méthode principale procédant à la fabrication des fiches de lecture
  def proceed_build_fiches_lecture
    puts "-> proceed_build_fiches_lecture"
    option?(:reload) && rapatriement_des_fiches_evaluations
    @projets_valides = evaluations_des_synopsis
    production_des_fiches(@projets_valides)
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
      # cmd = "scp -C -r -p -q #{SSH_ICARE_SERVER}:www/_lib/data/concours/**/evaluation-*.json #{mkdir(data_folder)}"
      cmd = "rsync -avm --include='*/' --include='evaluation-*.json' --exclude='*' #{SSH_ICARE_SERVER}:www/_lib/data/concours/ #{mkdir(data_folder)}"
      # Options :
      #   a : archiver => récursif
      #   m : prune empty dirs (ne les copie pas)
      #   v : verbose
      puts "Command RSync: #{cmd.inspect}"
      res = `#{cmd} 2>&1`
      if false
        puts "Retour de rsync : #{res.gsub(/\\n/,"\n")}"
      end

      # DATA_CONCOURS.merge!(data_concurrents)
      # puts "DATA_CONCOURS: #{data_concurrents.pretty_inspect}"
    end
  end #/ rapatriement_des_fiches_evaluations


  # Note : on ne doit traiter que les projets qui ont un dossier conforme
  def evaluations_des_synopsis
    suivi("\n== Évaluation des synopsis ==", :bleu)
    sans_fiches_evaluation = []
    avec_fiches_evaluation = []
    concurrents(:with_projet_conforme).each do |cid, cdata|
      projet = Projet.new(cdata)
      puts "- Étude du projet “#{cdata[:titre]}” de #{cdata[:patronyme]}"
      if projet.fichable?
        avec_fiches_evaluation << projet
      else
        sans_fiches_evaluation << projet
      end
    end
    line_info('Projets avec fiches d’évaluation : ', avec_fiches_evaluation.count)
    line_info('Projets sans fiches d’évaluation : ', sans_fiches_evaluation.count)
    # On définit la position de chaque projet
    avec_fiches_evaluation.sort_by { |projet| projet.note }.reverse.each_with_index do |projet, idx|
      projet.position = 1 + idx
    end

    return avec_fiches_evaluation
  end #/ evaluations_des_synopsis

  def production_des_fiches(projets)
    suivi("\n== Production des fiches de lecture ==", :bleu)
    projets.each do |projet|
      projet.fiche_lecture.build
    end
  end #/ production_des_fiches

end # /<< self
end #/FLFactory
