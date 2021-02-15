# encoding: UTF-8
# frozen_string_literal: true

class FLFactory
class << self
  attr_reader :projets_valides

  # = main =
  #
  # Méthode principale procédant à la fabrication des fiches de lecture
  # Ou de la fiche de lecture du concurrent d'identifiant +concurrent_id+
  def proceed_build_fiches_lecture(concurrent_id = nil)
    require_folder(CALCUL_FOLDER)
    option?(:reload) && begin
      rapatriement_des_fiches_evaluations
      rapatriement_notes_per_categorie
    end

    # return # Pour l'essai de rapatriement

    @projets_valides = evaluations_des_synopsis
    if concurrent_id
      @projets_valides = @projets_valides.select {|projet| projet.concurrent_id == concurrent_id}
    end
    if not @projets_valides.empty?
      production_des_fiches(@projets_valides)
    elsif concurrent_id.nil?
      erreur "Aucun projet susceptible d'être traité… Pas de fiches de lecture."
    else
      erreur "Le projet du concurrent #{concurrent_id} ne semble pas traitable…"
    end
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
      # puts "Command RSync: #{cmd.inspect}"
      res = `#{cmd} 2>&1`
      if false
        puts "Retour de rsync : #{res.gsub(/\\n/,"\n")}"
      end

    end
  end #/ rapatriement_des_fiches_evaluations

  def rapatriement_notes_per_categorie
    require './_dev_/CLI/lib/commands/concours/download'
    suivi("\n== Rapatriement des notes par catégorie ==", :bleu)
    suivi("== Dossier de réception : #{data_folder}", :bleu)
    if mode_tests?
      suivi("   MODE TESTS => Pas de rapatriement")
      return
    end
    # On n'est pas en mode test il faut ramener les évaluations des
    # synopsis.
    # cmd = "scp -C -r -p -q #{SSH_ICARE_SERVER}:www/_lib/data/concours/**/evaluation-*.json #{mkdir(data_folder)}"
    cmd = "rsync -avm --include='*/' --include='note-*.md' --exclude='*' #{SSH_ICARE_SERVER}:www/_lib/data/concours/ #{mkdir(data_folder)}"
    # Options :
    #   a : archiver => récursif
    #   m : prune empty dirs (ne les copie pas)
    #   v : verbose
    # puts "Command RSync: #{cmd.inspect}"
    res = `#{cmd} 2>&1`
    if not false
      puts "Retour de rsync : #{res.gsub(/\\n/,"\n")}"
    end
  end #/ rapatriement_notes_per_categorie


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
    line_info('= Projets avec fiches d’évaluation : ', avec_fiches_evaluation.count)
    line_info('= Projets sans fiches d’évaluation : ', sans_fiches_evaluation.count)
    # On définit la position de chaque projet
    print "Calcul de la position respective des projets…".bleu
    sorted_by_note = avec_fiches_evaluation.sort_by { |projet| projet.note }.reverse
    sorted_by_note.each_with_index do |projet, idx|
      projet.position = 1 + idx
    end
    puts "\r= Calcul de la position respective des projets effectué".vert
    sorted_by_note.each do |projet|
      puts "#{projet.position}. “#{projet.titre}” de #{projet.patronyme}"
    end

    return avec_fiches_evaluation
  end #/ evaluations_des_synopsis

  # Méthode qui construit véritablement les fiches
  # Cette construction peut dépendre des options (qui peuvent être combinées) :
  #   --only_one    Une seule fiche est produite, puis on s'arrête
  #   --not_built   On ne produit que des fiches inexistantes
  #   --only_bad    Seulement les fiches qui n'ont pas la moyenne
  #   --only_good   Seulement les fiches qui ont la moyenne
  def production_des_fiches(projets)
    suivi("\n== Production des fiches de lecture ==", :bleu)
    projets.each do |projet|
      next if option?(:only_good) && projet.evaluation.note < 10
      next if option?(:only_bad)  && projet.evaluation.note > 10
      next if option?(:not_built) && projet.fiche_lecture.built?
      print "Production fiche lecture projet “#{projet.titre}” (#{projet.concurrent_id})…".bleu
      projet.fiche_lecture.build
      puts "\r= Fiche du projet “#{projet.titre}” (#{projet.concurrent_id}) produite avec succès".vert
      break if option?(:only_one)
    end
  end #/ production_des_fiches

end # /<< self
end #/FLFactory
