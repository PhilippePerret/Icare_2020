# encoding: UTF-8
# frozen_string_literal: true
require_relative './Evaluation'

module EvaluationMethodsModule

  attr_reader :evaluation, :evaluation_totale

  # Note qui doit servir de note de classement en fonction du contexte
  attr_accessor :sort_note

  # Retourne une instance {Evaluation} correspondant aux arguments transmis
  # Si +options+ contient all: true, c'est une évaluation de tous les synopsis
  # Si +options+ définit evaluator:, c'est une évaluation pour le membre du jury
  # correspondant
  # +options+
  #   :evaluator  Défini si c'est seulement la fiche d'évaluation de l'évalua-
  #               teur transmis. Si non défini, cela signifie qu'il faut
  #               toutes les évaluations.
  #   :prix       TRUE s'il s'agit d'une évaluation pour les prix
  #
  def calc_evaluation_for(options)
    @evaluation = Evaluation.new(score_paths_for(options))
  end #/ evaluation

  def calc_evaluation_for_all(options)
    @evaluation_totale = Evaluation.new(score_paths_for(options.merge(evaluator:nil)))
  end #/ calc_evaluation_for_all

# ---------------------------------------------------------------------
#
#   Méthodes raccourcies
#
#   Note : toutes ces méthodes font références à la propriété :evaluation
#   qui a été calculée avec :calc_evaluation_for ci-dessus.
# ---------------------------------------------------------------------

# La note de l'évaluateur
def note
  evaluation.note
end #/ note

# La note totale des présélections pour le synopsis
def note_pres
  evaluation_totale.note_pres
end #/ note_totale

# La note totale du palmarès pour le synopsis
# TODO Réfléchir encore à la pertinence de ce choix. Peut-être vaudrait-il
# mieux additionner toutes les notes, même si ce total peut être inférieur à
# des notes de synopsis non présélectionnés
def note_prix
  evaluation_totale.note_prix
end #/ note_prix

def pourcentage
  evaluation.pourcentage
end #/ pourcentage

def pourcentage_total
  evaluation_totale.pourcentage
end #/ pourcentage_total

# ---------------------------------------------------------------------
#
#   Méthodes d'helper
#
# ---------------------------------------------------------------------

def formated_note
  @formated_note ||= formate_float(note)
end

def formated_pourcentage
  @f_pourcentage ||= "#{pourcentage} %"
end #/ formated_pourcentage

# IN    {Symbol} Une catégorie (p.e. :coherence, :personnages, :intrigues)
# OUT   {String} La note à afficher
def fnote_categorie(cate)
  formate_float(synopsis.evaluation.note_categorie(cate))
end #/ note_categorie

# ---------------------------------------------------------------------
#
#   Méthodes privées
#
# ---------------------------------------------------------------------


  # Retourne la liste DES scores du synopsis ou DU score de l'évaluateur
  # options[:evaluator].
  # Note : dans tous les cas, c'est une liste qui est retournée.
  def score_paths_for(options)
    ktype = options[:prix] ? 'prix' : 'pres'
    owner = options[:evaluator] ? options[:evaluator].id : '*'
    tempname = "evaluation-#{ktype}-#{owner}.json"
    Dir["#{folder}/#{tempname}"]
  end #/ score_paths_for
end #/EvaluationMethodsModule
