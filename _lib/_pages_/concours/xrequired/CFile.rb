# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class Concours::CFile
  ---------------------
  Pour la gestion du fichier de candidature
=end
class Concours
class CFile
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent, :annee
attr_reader :original_name
# Instance {Synopsis} du Synopsis associé au fichier, par exemple pour
# obtenir synopsis.titre
attr_reader :synopsis
def initialize(concurrent, annee, synopsis = nil)
  @concurrent = concurrent
  @annee      = annee
  @synopsis   = synopsis # dans administration
end #/ initialize

# Le nom conforme du fichier
def name
  @name ||= "#{concurrent.id}-#{annee}#{@extname}"
end #/ name

# Le path conforme du fichier
def path
  @path ||= File.join(concurrent.folder,name).tap{|p|`mkdir -p #{File.dirname(p)}`}
end #/ path

def bind; binding() end

end #/Concours::CFile
end #/Concours
