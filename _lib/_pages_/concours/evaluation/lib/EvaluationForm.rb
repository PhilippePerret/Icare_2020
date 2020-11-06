# encoding: UTF-8
# frozen_string_literal: true
=begin
  Class EvaluationForm
  --------------------
  Pour l'évaluation d'un synopsis

  Ici, la classe et l'instance sont deux entités presques séparées dans le
  sens où la classe va gérer le formulaire en tant que formulaire alors que
  l'instance va plutôt gérer l'évaluation.
=end
# Pour mettre tous les full-id créés et trouver éventuellement les doublons


class EvaluationForm
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
# Instance Synopsis du synopsis visé par l'évaluation
attr_reader :synopsis
# Instance User de l'évaluateur du synopsis
attr_reader :evaluateur
def initialize(synopsis, evaluateur)
  @synopsis = synopsis
  @evaluateur = evaluateur
end #/ initialize

# Sortie HTML du formulaire d'évaluation du synopsis
def out

end #/ out

# Sauvegarde de l'évaluation
def save

end #/ save

# Méthode appelée pour informer les autres évaluateurs qu'une évaluation
# a été créée ou actualisée.
def warn_other_evaluateur

end #/ warn_other_evaluateur

# Données d'évaluation, c'est-à-dire les notes attribuées par l'évaluateur
# À ne pas confondre avec +data+ du constructor qui sont les données
# absolues d'évaluation.
def data
  @data ||= begin
    if File.exists?(path)
      JSON.parse(File.read(path))
    else
      {}
    end
  end
end #/ data

# Chemin d'accès au fichier d'évaluation (pour le synopsis donné et l'évaluateur
# donné)
def path
  @path ||= begin
    fname = if synopsis.preselected? && Concours.current.phase3?
              filename_evaluation_prix
            else
              filename_evaluation_preselection
            end
    #
    File.join(synopsis.folder, fname)
  end
end #/ path

def filename_evaluation_prix
  synopsis.file_evaluation_per_phase_and_evaluator(3)
end
def filename_evaluation_preselection
  synopsis.file_evaluation_per_phase_and_evaluator(1)
end
end #/EvaluationForm
