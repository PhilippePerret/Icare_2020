# encoding: UTF-8
# frozen_string_literal: true
DEEPNESS_COEF = {}
(1..20).each do |i|
  DEEPNESS_COEF.merge!( i => 1.0 - ( (i - 1).to_f / 10 )) # 1 => 1, 2 => 0.9, 3 => 0.8
end

def calculer_note_generale(score)
  n = 0.0
  nombre_questions = score.count
  nombre_reponses  = 0
  score.each do |k, v|
    if v == "-"
    else
      coef = DEEPNESS_COEF[k.split('-').count]
      n += v * coef
      nombre_reponses += 1
    end
  end
  n = (4 * ( n / nombre_reponses )).round(1)
  pct = (100.0 / (nombre_questions.to_f / nombre_reponses)).round(1)
  return {note_generale: n, pourcentage_reponses: pct}
end #/ calculer_note_generale

begin
  evaluator   = Ajax.param(:evalutor)
  synopsis_id = Ajax.param(:synopsis_id)
  score       = Ajax.param(:score)
  log("evaluator: #{evaluator}, synopsis_id:#{synopsis_id}, score:#{score}")

  resultats = calculer_note_generale(score)
  log("résultat: #{resultats.inspect}")
  # Ajax << {note_generale:resultats[:note_generale], pourcentage_reponses: resultats[:pourcentage_reponses]}
  Ajax << resultats
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
