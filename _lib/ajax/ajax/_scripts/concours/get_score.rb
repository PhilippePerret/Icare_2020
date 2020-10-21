# encoding: UTF-8
# frozen_string_literal: true
require 'json'

Dir.chdir(APP_FOLDER) do
  require './_lib/_pages_/concours/xrequired/constants'
  require './_lib/_pages_/concours/xmodules/evaluation/module_calculs'
end

begin
  evaluator   = Ajax.param(:evaluator)
  synopsis_id = Ajax.param(:synopsis_id)
  concurrent_id, annee = synopsis_id.split('-')
  scores_folder_path = File.join(CONCOURS_DATA_FOLDER,concurrent_id,synopsis_id)
  score_path = File.join(scores_folder_path, "evaluation-#{evaluator}.json")
  score = {}
  if File.exists?(scores_folder_path)
    if File.exists?(score_path)
      score = JSON.parse(File.read(score_path))
    end
  end

  Ajax << {data_score: {
    evaluator:evaluator,
    synopsis_id:synopsis_id,
    score: score,
    nombre_questions: File.read(NOMBRE_QUESTIONS_PATH).to_i
    }}
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
