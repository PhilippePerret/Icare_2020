# encoding: UTF-8
# frozen_string_literal: true
=begin
  La classe Synopsis pour la gestion d'un synopsis
  Un synopsis est désigné par un :concurrent_id (identifiant du concurrent)
  et une année (année du concours).
  Noter que l'instance existe même lorsque le fichier de candidature n'a
  pas été envoyé. Mais dans ce cas, l'évaluation n'est pas encore possible.
=end
class Synopsis

# Pour récupérer les données d'un ~synopsis en particulier.
REQUEST_SYNOPSIS = <<-SQL
SELECT *
  FROM #{DBTBL_CONCURS_PER_CONCOURS}
  WHERE concurrent_id = ? AND annee = ?
SQL

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

# On prend tous les participants et ceux qui n'ont pas
# encore envoyé de synopsis, le synopsis est marqué "ghost"
REQUEST_ALL_CONCURRENTS = <<-SQL
SELECT
  cc.concurrent_id, cc.patronyme,
  cpc.*, (SUBSTRING(cpc.specs,1,1) = "1") AS with_fichier
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCURRENTS} cc ON cc.concurrent_id = cpc.concurrent_id
  WHERE cpc.annee = ? -- AND SUBSTRING(cpc.specs,1,1) = "1"
SQL

  # Retourne la liste de tous les synopsis courants (sous forme d'instances
  # synopsis). Note : il y en a une par concurrent de la session courante,
  # même s'il n'a pas encore envoyé son fichier de candidature
  # Processus :
  #   On relève dans la base les concurrents de l'année courante
  #
  def all_courant
    @all_courant ||= begin
      db_exec(REQUEST_ALL_CONCURRENTS, [ANNEE_CONCOURS_COURANTE]).collect do |dc|
        log("dc : #{dc.inspect}")
        Synopsis.new(dc[:concurrent_id], ANNEE_CONCOURS_COURANTE, dc)
      end
    end
  end #/ all_courant

  # OUT   Liste Array des instances de Synopsis, classés par note
  def all_sorted
    @all_sorted ||= begin
      sorteds = all_courant.dup.sort_by { |syno| syno.fiche_lecture.total.note }.reverse
      sorteds.each_with_index { |syno, idx| syno.position = idx + 1 unless syno.fiche_lecture.total.undefined? }
      sorteds
    end
  end #/ all_sorted
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
# Position de classement par rapport à la note
attr_accessor :position
# Instanciation
def initialize concurrent_id, annee, data = nil
  @concurrent_id = concurrent_id
  @annee = annee
  @id = "#{concurrent_id}-#{annee}"
  @data = data
end #/ initialize

# Pour la fiche du synopsis
# -------------------------
TEMPLATE_FICHE_SYNOPSIS = <<-HTML
<div id="synopsis-%{id}" class="%{class}" data-id="%{id}">
  <div id="synopsis-%{id}-titre" class="titre">%{titre}</div>
  <div class="auteur">de <span id="synopsis-%{id}-pseudo" class="">%{pseudo}</span></div>
  <div id="synopsis-%{id}-note-generale" class="note-generale">%{note}</div>
  <div id="synopsis-%{id}-pct-reponses" class="div-pct-reponses"><span class="pct-reponses">%{pct_reponses}</span> %%</div>
  <div id="synopsis-%{id}-jauge-pct-reponses" class="jauge-pct-reponses">
    <span class="jauge-pct-reponses-done" style="width:%{pct_reponses}%%;"></span>
  </div>
  <div id="synopsis-%{id}-keywords" class="keywords">%{keywords}</div>
  <div class="fiche-buttons" class="right">
    <a class="btn-edit small btn" href="concours/evaluation?view=body_form_synopsis&synoid=%{id}">Éditer</a>
    <button type="button" class="btn-evaluate small btn">Évaluer</button>
  </div>
  <div class="synopsis-id">%{id}</div>
</div>
HTML

def out(evaluator_id)
  @evaluator_id = evaluator_id
  TEMPLATE_FICHE_SYNOPSIS % {
    id:"#{concurrent_id}-#{annee}",
    class:css_classes,
    titre: titre,
    pseudo: concurrent.patronyme,
    note: note_generale,
    pct_reponses: pourcentage_reponses,
    keywords: formated_keywords # Pour se remémorer le synopsis
  }
end #/ out

def css_classes
  @css ||= begin
    c = ["synopsis"]
    c << "ghost" if not(fichier?)
    c.join(' ')
  end
end #/ css
# Pour sauver les données
def save(data)
  if data.key?(:keywords)
    data[:keywords] = data[:keywords].split(',').collect{|w|w.strip}.join(',')
  end
  if data.key?(:titre)
    raise("Il faut un titre !") if data[:titre].nil_if_empty.nil?
  end
  values  = data.values
  columns = data.keys.collect { |k| "#{k} = ?" }.join(", ")
  values << concurrent_id
  values << annee
  db_exec("UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET #{columns} WHERE concurrent_id = ? AND annee = ?", values)
  # Pour actualiser
  data.each {|k,v| instance_variable_set("@#{k}", v)}
end #/ save

def titre;    @titre    ||= data[:titre]    end
def auteurs;  @auteurs  ||= data[:auteurs]  end
def keywords; @keywords ||= data[:keywords] end

def real_auteurs
  auteurs || concurrent.patronyme
end #/ formated_auteurs

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

def formated_keywords
  @formated_keywords ||= data[:keywords].split(',').collect{|kw| "<span class=\"kword\">#{kw}</span>"}.join(' ')
end #/ keywords

# Son instance de formulaire d'évaluation, pour un évaluateur donné
def evaluation(evaluateur)
  @evaluations ||= {}
  @evaluations[evaluateur.id] || begin
    @evaluations.merge!(evaluateur.id => EvaluationForm.new(self, evaluateur))
  end
  @evaluations[evaluateur.id]
end #/ evaluation

# ---------------------------------------------------------------------
#   Méthodes d'état
# ---------------------------------------------------------------------

# OUT   True si le fichier a été envoyé
def fichier?
  data[:with_fichier] == 1
end #/ fichier?

# ---------------------------------------------------------------------
#   Méthods de chemins
# ---------------------------------------------------------------------

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
