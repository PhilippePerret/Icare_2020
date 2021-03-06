# encoding: UTF-8
=begin
  Pour consigner un paiement

  Le script est appelé quand l'icarien clique sur le bouton pour payer
  son module. Il permet d'initier un nouveau paiement avec l'identifiant
  envoyé.
=end
begin

  log(":value = #{Ajax.param(:value)}")
  # Ajax << {message: "J'ai reçu le message : “#{Ajax.param(:value)}”"}

  # Ajax << {
  #   message:"Le script essai.rb a été joué avec succès."
  # }
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
