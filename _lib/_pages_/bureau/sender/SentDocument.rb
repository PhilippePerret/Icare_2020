# encoding: UTF-8
=begin
  Class SentDocument
  ------------------
  Pour gérer les documents envoyés
=end

class SentDocument
EXTENSIONS_VALIDES = ['.odt','.rtf','.md','.mmd','.txt','.text','.pdf','.doc','.docx']
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

  # Détruit le dossier de l'user +owner+ de type +type+
  # +type+, par exemple, peut être 'sent-work' pour les documents envoyés.
  def remove_user_folder(owner, type)
    dossier = user_folder(owner, type)
    FileUtils.rm_rf(dossier) if File.exists?(dossier)
  end #/ remove_folder

  # Dossier qui doit contenir tous les documents de l'user courant
  def user_folder(owner, type)
    File.join(DOWNLOAD_FOLDER,type,"user-#{owner.id}")
  end #/ folder

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :id, :data, :docfile, :idoc, :type, :owner
attr_accessor :error # l'erreur éventuelle que comporte le document
def initialize(data)
  @owner    = data[:owner]
  @docfile  = data[:docfile]
  @type     = data[:type]     # p.e. 'sent-work'
  @idoc     = data[:idoc]
end #/ initialize

# Méthode qui retourne true si le document à envoyer est valide
# Il doit avoir la bonne extension et avoir un contenu
def valid?
  EXTENSIONS_VALIDES.include?(extension) || begin
    self.error = 'format invalide'
    return false
  end
  size > 0 || begin
    self.error = 'document sans contenu'
    return false
  end
  # Un traitement propre
  return check if respond_to?(:check)

  return true
end #/ valid?

# Méthode pour traiter le document :docfile venant d'un formulaire
def traite
  if respond_to?(:check)
    return unless self.check
  end
  File.open(path,'wb'){|f| f.write content }
end #/ traite

# Contenu du fichier
def content
  @content ||= docfile.read
end #/ content

def original_filename
  @original_filename ||= docfile.original_filename
end #/ original_filename

def extension
  @extension ||= File.extname(original_filename)
end #/ extension

def size
  @size ||= docfile.size
end #/ size

def path
  @path ||= File.join(folder, original_filename)
end #/ path

def folder
  @folder ||= mkdir(File.join(DOWNLOAD_FOLDER,type,"user-#{owner.id}".freeze))
end #/ folder

end #/SentDocument
