# encoding: UTF-8
# frozen_string_literal: true

require './_lib/_pages_/concours/xrequired/constants_mini'

class FLFactory
class << self
  # = main =
  #
  # Méthode principale affichant les informations concernant les fiches
  # de lecture
  def show_infos_fiches_lecture
    puts "\n\n"
    line_info('Nombre total de concurrents', concurrents.count)
    line_info('Concurrents avec projets', concurrents(:with_projet).count)
    line_info('Concurrents avec projets conformes', concurrents(:with_projet_conforme).count)

    puts "\n\n"

    # Doit-on afficher une évaluation ? (c'est utile surtout pour l'implémen-
    # tation, pour savoir comment est constitué projet.evaluation)
    if option?(:evaluation)
      require './_dev_/Concours_synopsis/FICHES_LECTURE/modules/build/Projet'
      require_folder(CALCUL_FOLDER)
      projet = nil
      concurrents(:with_projet_conforme).each do |cid, cdata|
        projet = Projet.new(cdata)
        # puts "- Étude du projet “#{cdata[:titre]}” de #{cdata[:patronyme]}"
        break if projet.fichable?
      end
      if projet
        puts "Évaluation du projet “#{projet.titre}” (#{projet.concurrent_id})"
        if option?(:full_version)
          puts projet.evaluation.pretty_inspect
        else
          # Version simplifiée, avec les clés et les notes
          projet.evaluation.categories.each do |k, dv|
            puts "#{k.inspect} => {note: #{dv[:note]}}"
          end
          puts "\n\n(ci-dessus, c'est une version simplifiée de l'évaluation)"
        end
        if option?(:with_files)
          # On affiche aussi le contenu des scores
          projet.evaluation.score_paths.each do |score_path|
            puts "Contenu du fichier #{File.basename(score_path).inspect} :"
            puts JSON.parse(File.read(score_path)).pretty_inspect
          end
        end
      else
        puts "Impossible de trouver un projet avec fiche d'évaluation en local…".rouge
      end

    else
      # S'il ne faut pas affiche l'évaluation

      Q.select("Que veux-tu faire maintenant ?") do |q|
        q.choices [{name:'Produire les fiches', value:'build'}, {name:'Uploader les fiches',value:'upload'}, {name:'S’arrêter là', value:'none'}]
        q.per_page 3
      end

    end

  end #/ proceed_build_fiches_lecture

end # /<< self
end #/FLFactory
