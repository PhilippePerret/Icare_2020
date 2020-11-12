# encoding: UTF-8
# frozen_string_literal: true
require 'json'

Dir.chdir(APP_FOLDER) do
  require './_lib/_pages_/concours/xrequired/constants'
  require './_lib/_pages_/concours/xrequired/Concurrent'
  require './_lib/_pages_/concours/xmodules/synopsis/Synopsis'
end

begin
  evaluator   = Ajax.param(:evaluator)
  synopsis_id = Ajax.param(:synopsis_id)
  score       = Ajax.param(:score)
  # --------------------------------------------
  concurrent_id, annee = synopsis_id.split('-')

  # On récupère la phase du concours d'année +annee+ (le plus souvent l'année
  # du concours courant)
  phase = db_exec("SELECT phase FROM concours WHERE annee = ?", [annee]).first[:phase]
  synopsis = Synopsis.new(concurrent_id, annee)
  score_path = synopsis.score_path_for(evaluator, phase)
  # `mkdir -p "#{File.dirname(score_path)}"`
  FileUtils.mkdir_p(File.dirname(score_path))
  File.open(score_path,'wb'){|f| f.write score.to_json }

  log("evaluator: #{evaluator}, synopsis_id:#{synopsis_id}, score:#{score}")

  evaluation = synopsis.evaluation_for(evaluator)

  log("Résultat de l'évaluation : #{evaluation.inspect}")
  # Ajax << {note:resultats[:note], pourcentage_reponses: resultats[:pourcentage_reponses]}
  Ajax << {note: evaluation.note, pourcentage_reponses: evaluation.pourcentage}

  # On doit réinitialiser pre_note ou fin_note en fonction de la phase pour
  # recalculer les changements
  prop_note = if phase == 1 || phase == 2
                'pre_note'
              elsif phase == 3
                'fin_note'
              else
                nil
              end
  # On update
  request = "UPDATE concurrents_per_concours SET #{prop_note} = ? WHERE concurrent_id = ? AND annee = ?"
  db_exec(request, [nil, concurrent_id, annee])

rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
