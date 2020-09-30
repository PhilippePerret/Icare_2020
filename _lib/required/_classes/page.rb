# encoding: UTF-8
# frozen_string_literal: true
class Page
class << self

  # Charge la page de chemin relatif +relpath+ (dans lib/_pages_)
  def load(relpath)
    relpath = relpath.route if relpath.instance_of?(Route)
    page = self.new(relpath)
    unless page.exists?
      param(:r, CGI.escape(relpath))
      page = self.new("errors/404")
    end
    page.load()
  end
end #/<< self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :relative
def initialize relpath
  @relative = relpath
end

def load
  load_xrequired
  require_folder(path)
end

# Charge les dossiers xrequired qui pourraient se trouver dans la hiérarchie
# de la route
def load_xrequired
  the_path = path.dup
  while the_path && File.basename(the_path) != '_pages_'
    the_path = File.dirname(the_path)
    path_xrequired = File.join(the_path,'xrequired')
    if File.exists?(path_xrequired)
      require_folder(path_xrequired)
    end
  end
end

def exists?
  File.exists?(path)
end
def path
  @path ||= File.join(PAGES_FOLDER,relative)
end
end #/Page
