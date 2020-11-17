# encoding: UTF-8
# frozen_string_literal: true
require 'json'

Dir.chdir(APP_FOLDER) do
  require './_lib/_pages_/concours/xrequired/constants'
  require './_lib/_pages_/concours/xrequired/Concurrent'
  require './_lib/_pages_/concours/xmodules/synopsis/Synopsis'
  require './_lib/_pages_/concours/evaluation/lib/Evaluator'
end

begin
  evaluator_id  = Ajax.param(:evaluator)
  synopsis_id   = Ajax.param(:synopsis_id)
  score         = Ajax.param(:score)
  # --------------------------------------------
  concurrent_id, annee = synopsis_id.split('-')
  evaluator = Evaluator.get(evaluator_id)

  # On récupère la phase du concours d'année +annee+ (le plus souvent l'année
  # du concours courant)
  phase       = db_exec("SELECT phase FROM concours WHERE annee = ?", [annee]).first[:phase]
  synopsis    = Synopsis.new(concurrent_id, annee)
  score_path  = synopsis.score_path_for(evaluator_id, phase)
  # `mkdir -p "#{File.dirname(score_path)}"`
  FileUtils.mkdir_p(File.dirname(score_path))
  File.open(score_path,'wb'){|f| f.write score.to_json }

  log("evaluator_id: #{evaluator_id}, synopsis_id:#{synopsis_id}, score:#{score}")

  # Pour retourner la nouvelle note, on doit faire l'évaluation de ce synopsis
  synopsis.calc_evaluation_for(evaluator: evaluator, prix: phase > 2)
  evaluation = synopsis.evaluation

  log("Résultat de l'évaluation : #{evaluation.inspect}")

  Ajax << {note: evaluation.note, pourcentage_reponses: evaluation.pourcentage}

rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
