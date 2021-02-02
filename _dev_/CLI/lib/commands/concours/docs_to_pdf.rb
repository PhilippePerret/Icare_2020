# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour transformer tous les documents en PDF
=end
class IcareCLI
class << self

require_relative './CDossier'

# = main =
#
# Transformer tous les documents en document PDF.
#
# Synopsis
# --------
#   - Rapatrie tous les documents
#
def proceed_concours_docs_to_pdf
  puts "Je regarde dans les projets du concours téléchargés et je fabrique les PDF qui ne sont pas produits".bleu
  Q.yes?("Dois-je faire cette opération ?") || return
  Dir["#{CDossier.folder}/*"].each do |fconc|
    concurrent_id = File.basename(fconc)
    Dir["#{fconc}/#{concurrent_id}-#{ANNEE_CONCOURS_COURANTE}.{odt,docx,rtf,txt,text,doc}"].each do |fdossier|
      ndossier = File.basename(fdossier)
      cdossier = CDossier.new(ndossier)
      if File.exists?(cdossier.local_pdf_path)
        puts "Le fichier #{cdossier.pdf_name.inspect} du fichier #{cdossier.name.inspect} existe.".vert
      else
        puts "Le fichier #{cdossier.pdf_name.inspect} du fichier #{cdossier.name.inspect} n'existe pas.".rouge
        cdossier.to_pdf && cdossier.upload_pdf
      end
    end
  end
end #/ proceed_docs_to_pdf

end # /<< self

end #/IcareCLI
