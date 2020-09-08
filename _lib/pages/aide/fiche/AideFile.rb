# encoding: UTF-8
# frozen_string_literal: true

ERRORS.merge!({
  unfound_aide_file: 'Le fichier d’aide est introuvable, malheureusement…'.freeze
})

class AideFile
include StringHelpersMethods

class << self
  def folder
    @folder ||= File.join(PAGES_FOLDER,'aide','data')
  end #/ folder
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :id, :fpath, :fextension
def initialize aide_id
  @id = aide_id.to_s
end #/ initialize
def out
  case fextension
  when '.md', '.erb'
    deserb_or_markdown(code, self)
  else
    code
  end
end

def code
  file_read(fpath)
end #/ code

def bind
  binding()
end #/ bind

# Retourne le nom du fichier d'aide, en le recherchant dans le
# dossier data par son id-nom
def fname
  @fname || find[:fname]
end #/ fname
def fextension
  @fextension || find[:fextension]
end #/ fextension
def fpath
  @fpath || find[:fpath]
end #/ fpath

# Méthode qui recherche le fichier d'aide d'après son id
def find
  log("id: #{id} / self.class.folder: #{self.class.folder.inspect}")
  if RUBY_VERSION > "2.5.7"
    @fname = Dir.glob("#{id}-*\.{md,erb}", base: self.class.folder).first || raise(ERRORS[:unfound_aide_file])
    @fpath = File.join(self.class.folder, @fname)
  else
    @fpath = Dir.glob("#{self.class.folder}/#{id}-*\.{md,erb}").first || raise(ERRORS[:unfound_aide_file])
  end
  @fextension = File.extname(@fpath)
  {fname: File.basename(@fpath), fpath: @fpath, fextension: @fextension}

end #/ find

end #/AideFile
