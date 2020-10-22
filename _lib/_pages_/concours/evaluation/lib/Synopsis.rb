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
  cc.concurrent_id, cc.patronyme,
  cpc.titre, cpc.keywords
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
        Synopsis.new(dc[:concurrent_id], ANNEE_CONCOURS_COURANTE, dc)
      end
    end
  end #/ all_courant
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent_id, :annee, :data, :id
# Les données de score pour un évaluator donné
# Note : pour le moment, l'évaluateur se donne dans :out
attr_reader :data_score, :evaluator_id
# Instanciation
def initialize concurrent_id, annee, data = nil
  @concurrent_id = concurrent_id
  @annee = annee
  @id = "#{concurrent_id}-#{annee}"
  @data = data
end #/ initialize

TEMPLATE_FICHE_SYNOPSIS = <<-HTML
<div id="synopsis-%{id}" class="synopsis" data-id="%{id}">
  <div id="synopsis-%{id}-titre" class="titre">%{titre}</div>
  <div class="auteur">de <span id="synopsis-%{id}-pseudo" class="">%{pseudo}</span></div>
  <div id="synopsis-%{id}-note-generale" class="note-generale">%{note}</div>
  <div id="synopsis-%{id}-pct-reponses" class="div-pct-reponses"><span class="pct-reponses">%{pct_reponses}</span> %%</div>
  <div id="synopsis-%{id}-jauge-pct-reponses" class="jauge-pct-reponses">
    <span class="jauge-pct-reponses-done" style="width:%{pct_reponses}%%;"></span>
  </div>
  <div id="synopsis-%{id}-keywords" class="keywords">%{keywords}</div>
  <div class="right">
    <button type="button" class="btn-evaluate small btn">Évaluer</button>
  </div>
</div>
HTML

def out(evaluator_id)
  @evaluator_id = evaluator_id
  TEMPLATE_FICHE_SYNOPSIS % {
    id:"#{concurrent_id}-#{annee}",
    titre: titre,
    pseudo: concurrent.patronyme,
    note: note_generale,
    pct_reponses: pourcentage_reponses,
    keywords: keywords # Pour se remémorer le synopsis
  }
end #/ out

def titre
  @titre ||= data[:titre]
end #/ titre

def concurrent
  @concurrent ||= Concurrent.get(concurrent_id)
end #/ concurrent

# Son instance de fiche de lecture
def fiche_lecture
  @fiche_lecture ||= FicheLecture.new(self)
end #/ fiche_lecture

def note_generale
  data_score || get_data_score
  data_score[:note_generale] || "---"
end #/ note_generale

def pourcentage_reponses
  data_score || get_data_score
  data_score[:pourcentage_reponses] || 0
end #/ pourcentage_reponses

def get_data_score
  dscore = {}
  if File.exists?(folder)
    score_evaluator_path = score_path(evaluator_id)
    if File.exists?(score_evaluator_path)
      dscore = JSON.parse(File.read(score_evaluator_path))
    end
  end
  @data_score = ConcoursCalcul.note_generale_et_pourcentage_from(dscore)
  if not dscore.empty?
    log("@data_score obtenu pour #{id} : #{@data_score.inspect}")
  end
end #/ data_score

def keywords
  @keywords ||= data[:keywords].split(',').collect{|kw| "<span class=\"kword\">#{kw}</span>"}.join(' ')
end #/ keywords

# Son instance de formulaire d'évaluation, pour un évaluateur donné
def evaluation(evaluateur)
  @evaluations ||= {}
  @evaluations[evaluateur.id] || begin
    @evaluations.merge!(evaluateur.id => EvaluationForm.new(self, evaluateur))
  end
  @evaluations[evaluateur.id]
end #/ evaluation

# Chemin d'accès au fichier d'évaluation (score) pour l'évaluator evaluator_id
def score_path(evaluator_id)
  File.join(folder, "evaluation-#{evaluator_id}.json")
end #/ score_path
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
