# encoding: UTF-8
=begin
  Class SentDocument
  ------------------
  Pour gérer les documents envoyés
=end
class SentDocument
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data, :docfile, :idoc, :type, :owner
def initialize(data)
  @owner    = data[:owner]
  @docfile  = data[:docfile]
  @type     = data[:type]     # p.e. 'sent-work'
  @idoc     = data[:idoc]
end #/ initialize

# Méthode pour traiter le document :docfile venant d'un formulaire
def traite
  if respond_to?(:check)
    return unless self.check
  end
  File.open(path,'wb'){|f| f.write docfile.read }
end #/ traite

def original_filename
  @original_filename ||= docfile.original_filename
end #/ original_filename

def path
  @path ||= File.join(folder, original_filename)
end #/ path

def folder
  @folder ||= mkdir(File.join(DOWNLOAD_FOLDER,type,"user-#{owner.id}".freeze))
end #/ folder

end #/SentDocument
