# encoding: UTF-8
# frozen_string_literal: true
=begin
  Exécution d'une requête DB

  @usage

    En javascript
    -------------
    Ajax.send("db_exec", {request: "<la requête mysql>"})
    .then(retour => {
      ... traitement du retour ....
    })
=end
begin
  # Ajax << {message: "Je passe par db_exec (#{respond_to?(:db_exec) ? "la méthode existe" : "la méthode n'existe pas"})"}
  request = Ajax.param(:request)
  response = db_exec(request)
  Ajax << {response: response}
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
