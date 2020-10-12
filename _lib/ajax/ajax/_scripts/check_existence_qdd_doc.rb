# encoding: UTF-8
# frozen_string_literal: true
=begin
  Méthode qui vérifie l'existence de document PDF sur le Quai des Docs
=end
begin
  relpathOriginal = Ajax.param(:original)
  relpathComments = relpathOriginal.sub(/_original\./,'_comments.')
  pathOriginal = nil
  pathComments = nil
  Dir.chdir(APP_FOLDER) do
    pathOriginal    = File.expand_path(relpathOriginal)
    pathComments    = File.expand_path(relpathComments)
  end

  Ajax << {
    original_exists: File.exists?(pathOriginal),
    comments_exists: File.exists?(pathComments),
    pathOriginal:pathOriginal,
    pathComments:pathComments
  }

  # Ajax << {
  #   message:"Le script essai.rb a été joué avec succès."
  # }
rescue Exception => e
  log("# ERREUR : #{e.message}")
  log("# Backtrace : #{e.backtrace.join("\n")}")
  Ajax << {error: "ERREUR FATALE : #{e.message} (consulter la console)", backtrace: e.backtrace}
end
