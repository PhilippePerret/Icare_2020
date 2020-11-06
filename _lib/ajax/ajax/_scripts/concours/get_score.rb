# encoding: UTF-8
# frozen_string_literal: true
=begin
  Script Ajax pour récupérer le score d'une fichier (en fonction de la phase)
=end
require 'json'

Dir.chdir(APP_FOLDER) do
  require './_lib/_pages_/concours/xrequired/constants'
  require './_lib/_pages_/concours/xmodules/evaluation/module_calculs'
  require './_lib/_pages_/concours/xmodules/synopsis/Synopsis'
end

begin
  evaluator   = Ajax.param(:evaluator)
  synopsis_id = Ajax.param(:synopsis_id)
  concurrent_id, annee = synopsis_id.split('-')
  # On récupère la phase du concours d'année +annee+ (le plus souvent l'année
  # du concours courant)
  phase = db_select("SELECT phase FROM concours WHERE annee = ?", [annee]).first[:phase]
  synopsis = Synopsis.new(concurrent_id, annee)
  score_path = synopsis.file_evaluation_per_phase_and_evaluator(phase, evaluator)
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
