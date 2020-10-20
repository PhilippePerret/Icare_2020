# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module de consignation du fichier de ccandidature
  class Concours::File
=end
class HTML
  def consigne_fichier_candidature
    file = Concours::CFile.new(concurrent, ANNEE_CONCOURS_COURANTE)
    if file.consigne_file(param(:p_fichier_candidature))
      message("Merci #{concurrent.pseudo}, votre fichier de candidature a bien été pris en compte.")
    end
  end #/ consigne_fichier_candidature
end #/HTML

class Concours
class CFile
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE FICHIER DE CANDIDATURE
#
# ---------------------------------------------------------------------
attr_reader :concurrent, :annee
def initialize(owner, annee)
  @concurrent = owner
  @annee      = annee
end #/ initialize


# Méthode appelée avec le champ file du formulaire pour consigner le fichier
def consigne_file(ffile) # ffile pour "form-file"
  ffile.size > 0 || raise("Ce fichier est vide…")
  ffile.size < 1000000 || raise("Ce fichier est trop volumineux (1Mo maximum — essayez de réduire la taille de l'image).")
  # Nom original et extension
  orname = ffile.original_filename
  @extname = File.extname(orname)
  extension_valide?(@extname) || raise("L'extension de ce fichier est invalide. Les extensions acceptées sont : #{EXTENSIONS_VALIDES.pretty_join}.")
  File.open(path,'wb') { |f| f.write ffile.read }
  # Si tout est OK, on marque que le dossier est envoyé dans les
  # specs du concurrent.
  concurrent.set_spec(0, 1)
  concurrent.save_specs

  return true # si tout est OK
rescue Exception => e
  log(e)
  return erreur(e.message)
end #/ consigne_file

# Le nom conforme du fichier
def name
  @name ||= "#{concurrent.id}-#{annee}#{@extname}"
end #/ name

# Le path conforme du fichier
def path
  @path ||= File.join(concurrent.folder,name).tap{|p|`mkdir -p #{File.dirname(p)}`}
end #/ path

private

  def extension_valide?(ext)
    EXTENSIONS_VALIDES.include?(ext)
  end #/ extension_valide?


EXTENSIONS_VALIDES = [
  '.pdf','.odt','.doc','.docx','.txt','.rtf','.md','.markdown','.rtfd'
]
end #/File
end #/Concours
