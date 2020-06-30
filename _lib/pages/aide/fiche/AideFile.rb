# encoding: UTF-8
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
  # inspect
  case fextension
  when '.md'
    AIKramdown.kramdown(fpath)
  when '.erb'
    deserb(fpath, self)
  else
    file_read(fpath)
  end
end

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
  Dir["#{self.class.folder}/*.{md,erb,html,htm}"].each do |path|
    afx = File.basename(path, File.extname(path))
    if afx == id || afx.start_with?(id)
      @fname = File.basename(path)
      @fextension = File.extname(path)
      @fpath = path
      break
    end
  end
  @fname || raise(ERRORS[:unfound_aide_file])
  {fname: @fname, fpath: @fpath, fextension: @fextension}
end #/ find

end #/AideFile
