# encoding: UTF-8
# frozen_string_literal: true


begin
  evaluator = Ajax.param(:evalutor)
  synopsis_id = Ajax.param(:synopsis_id)

  Ajax << {score: {"p":{value:13}}}
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
