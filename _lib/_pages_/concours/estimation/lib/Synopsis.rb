# encoding: UTF-8
# frozen_string_literal: true
=begin
  La classe Synopsis pour la gestion d'un synopsis
  Un synopsis est désigné par un :concurrent_id (identifiant du concurrent)
  et une année (année du concours).
=end
class Synopsis
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent_id, :annee
def initialize concurrent_id, annee
  @concurrent_id = concurrent_id
  @annee = annee
end #/ initialize

# Son instance de fiche de lecture
def fiche_lecture
  @fiche_lecture ||= FicheLecture.new(self)
end #/ fiche_lecture

# Son instance de formulaire d'évaluation, pour un évaluateur donné
def evaluation(evaluateur)
  @evaluations ||= {}
  @evaluations[evaluateur.id] || begin
    @evaluations.merge!(evaluateur.id => EvaluationForm.new(self, evaluateur))
  end
  @evaluations[evaluateur.id]
end #/ evaluation

# Chemin d'accès au dossier du synopsis, où sont rangées tous les fichiers,
# et notamment les fichiers d'évaluation
def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER,concurrent_id,affixe).tap{|p|`mkdir -p "#{p}"`}
end #/ folder

# Chemin d'accès au fichier synopsis
# Puisque le path est trouvé de façon dynamique, on peut interroger path.nil?
# pour savoir si le fichier existe.
def path
  @path ||= begin
    Dir["#{CONCOURS_DATA_FOLDER}/#{concurrent_id}/#{affixe}.*"].first
  end
end #/ path

def affixe
  @affixe ||= "#{concurrent_id}-#{annee}"
end #/ affixe
end #/Synopsis
