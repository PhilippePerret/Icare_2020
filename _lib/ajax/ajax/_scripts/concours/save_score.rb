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
  score       = Ajax.param(:score)
  concurrent_id, annee = synopsis_id.split('-')
  scores_folder_path = File.join(CONCOURS_DATA_FOLDER,concurrent_id,synopsis_id)
  score_path = File.join(scores_folder_path, "evaluation-#{evaluator}.json")
  `mkdir -p "#{scores_folder_path}"`
  File.open(score_path,'wb'){|f| f.write score.to_json }

  log("evaluator: #{evaluator}, synopsis_id:#{synopsis_id}, score:#{score}")

  resultats = ConcoursCalcul.note_generale_et_pourcentage_from(score)
  log("Résultat des calculs : #{resultats.inspect}")
  # Ajax << {note_generale:resultats[:note_generale], pourcentage_reponses: resultats[:pourcentage_reponses]}
  Ajax << resultats
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
