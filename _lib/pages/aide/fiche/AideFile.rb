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
  when '.md', '.erb'
    deserb_or_markdown(fpath, self)
    # AIKramdown.kramdown(fpath, self)
  # when '.erb'
  #   deserb(fpath, self)
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
  @fname = Dir.glob("#{id}-*\.{md,erb}", base:self.class.folder).first
  @fname || raise(ERRORS[:unfound_aide_file])
  @fpath = File.join(self.class.folder, @fname)
  @fextension = File.extname(@fname)
  {fname: @fname, fpath: @fpath, fextension: @fextension}

  # Dir["#{}/*.{md,erb}"].each do |path|
  #   afx = File.basename(path, File.extname(path))
  #   if afx == id || afx.start_with?(id)
  #     @fname = File.basename(path)
  #     @fextension = File.extname(path)
  #     @fpath = path
  #     break
  #   end
  # end
end #/ find

end #/AideFile
