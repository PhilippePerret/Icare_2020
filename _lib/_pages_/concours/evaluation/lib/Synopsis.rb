# encoding: UTF-8
# frozen_string_literal: true
=begin
  La classe Synopsis pour la gestion d'un synopsis
  Un synopsis est désigné par un :concurrent_id (identifiant du concurrent)
  et une année (année du concours).
=end
class Synopsis
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

REQUEST_ALL_CONCURRENTS_WITH_SYNOPSIS = <<-SQL
SELECT
  cc.concurrent_id, cc.patronyme
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ? AND SUBSTRING(cpc.specs,1,1) = "1"
SQL

  # Retourne la liste de tous les synopsis courants (sous forme d'instances
  # synopsis).
  # Processus :
  #   On relève dans la base les concurrents de l'année courante
  #   Mais seulement ceux qui ont déposé leur synopsis
  #
  def all_courant
    @all_courant ||= begin
      db_exec(REQUEST_ALL_CONCURRENTS_WITH_SYNOPSIS, [ANNEE_CONCOURS_COURANTE]).collect do |dc|
        Synopsis.new(dc[:concurrent_id], ANNEE_CONCOURS_COURANTE)
      end
    end
  end #/ all_courant
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

TEMPLATE_FICHE_SYNOPSIS = <<-HTML
<div id="synopsis-%{id}" class="synopsis">
  <div class="titre">de %{pseudo}</div>
  <div id="synopsis-%{id}-note-generale" class="note-generale">%{note}</div>
</div>
HTML
def out
  TEMPLATE_FICHE_SYNOPSIS % {id:"#{concurrent_id}-#{annee}", pseudo: concurrent.patronyme, note: note_generale}
end #/ out

def concurrent
  @concurrent ||= Concurrent.get(concurrent_id)
end #/ concurrent

# Son instance de fiche de lecture
def fiche_lecture
  @fiche_lecture ||= FicheLecture.new(self)
end #/ fiche_lecture

def note_generale
  12
end #/ note_generale

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
