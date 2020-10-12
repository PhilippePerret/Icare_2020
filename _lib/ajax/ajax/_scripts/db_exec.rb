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
  values  = Ajax.param(:values)
  return_id     = Ajax.param(:sql_id)
  return_table  = Ajax.param(:sql_table)
  log("Requête à exécuter avec les valeurs #{values.inspect} : #{request.inspect}")
  sql_response =
    if values.nil?
      db_exec(request)
    else
      db_exec(request, values)
    end
  newdata = nil
  if return_id && return_table
    newdata = db_get(return_table, return_id)
  end
  Ajax << {
    response: sql_response,
    message: "Requête exécutée avec succès.",
    new_data: newdata
  }
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
