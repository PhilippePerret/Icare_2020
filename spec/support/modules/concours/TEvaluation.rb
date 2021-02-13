# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module pour gérer les évaluations (score)
=end
class TEvaluation
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

attr_reader :evaluator_id, :synopsis_id, :concurrent_id, :annee

# Pour initialiser, on envoie soit l'instance TEvaluator, soit son
# identifiant.
def initialize(evaluator_id, synopsis_id)
  evaluator_id = evaluator_id.id if evaluator_id.respond_to?(:id)
  @evaluator_id = evaluator_id
  @synopsis_id  = synopsis_id
  @concurrent_id, @annee = synopsis_id.split('-')
end #/ initialize

# Les données dans le fichier
def data
  @data ||= JSON.parse(File.read(path))
end

def evaluator
  @evaluator ||= TEvaluator.get(evaluator_id)
end #/ evaluator

# Chemin d'accès (qui dépend du jury auquel appartient l'évaluator)
def path
  @path ||= begin
    if evaluator.jury1?
      path_preselection
    else
      path_prix
    end
  end
end
# Chemin d'accès à l'évaluation pour les présélections
def path_preselection
  @path_preselection ||= File.join(folder, "evaluation-pres-#{evaluator_id}.json")
end #/ path
# Chemin d'accès à l'évaluation pour le prix (jury 2)
def path_prix
  @path_prix ||= File.join(folder, "evaluation-prix-#{evaluator_id}.json")
end #/ path

# Chemin d'accès au fichier de l'évaluation, c'est-à-dire la dossier propre
# au concours courant
def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER, concurrent_id, synopsis_id)
end #/ folder

end #/TEvaluation
