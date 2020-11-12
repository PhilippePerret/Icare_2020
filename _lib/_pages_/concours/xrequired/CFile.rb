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

# OUT   True si la conformité a été définie (i.e. le bit 2 est différent
#       de 0 — mais il peut être égal à 1:conforme ou 2:non conforme)
def conformity_defined?
  concurrent.spec(1) != 0
end #/ conformity_defined?

# OUT   True si la conformité du synopsis a été marquée
def conforme?
  concurrent.spec(1) == 1
end

def sent?
  concurrent.spec(0) == 1
end #/ sent?

# Retourne TRUE quand le fichier de candidature a été marqué non conforme
# et que le concurrent doit le modifier.
def to_modify?
  concurrent.spec(1) == 2
end #/ to_modify?


end #/Concours::CFile
end #/Concours
