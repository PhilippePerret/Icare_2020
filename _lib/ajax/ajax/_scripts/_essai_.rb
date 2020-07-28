# encoding: UTF-8
=begin
  Pour faire des essais
=end
begin

  Ajax << {message: "J'ai reçu le message : “#{Ajax.param(:message)}”"}

  # Ajax << {
  #   message:"Le script essai.rb a été joué avec succès."
  # }
rescue Exception => e
  Ajax.error(e)
end
