# encoding: UTF-8
# frozen_string_literal: true
require_relative './Evaluation'

module EvaluationMethodsModule

  attr_reader :evaluation, :evaluation_totale

  # Note qui doit servir de note de classement en fonction du contexte
  # attr_accessor :sort_note

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
  end

  def calc_evaluation_for_all(options)
    options ||= { prix: Concours.current.phase > 3 }
    @evaluation_totale = Evaluation.new(score_paths_for(options.merge(evaluator:nil)))
  end

# ---------------------------------------------------------------------
#
#   Méthodes raccourcies
#
#   Note : toutes ces méthodes font références à la propriété :evaluation
#   qui a été calculée avec :calc_evaluation_for ci-dessus.
# ---------------------------------------------------------------------

# La note de l'évaluateur
def note
  evaluation&.note || 'NC'
end

def note_totale
  @note_totale ||= Concours.current.phase < 3 ? note_pres : note_prix
end

# La note totale des présélections pour le synopsis
def note_pres
  # evaluation_totale&.note_pres || 'NC'
  evaluation_totale&.note || 'NC'
end

# La note totale du palmarès pour le synopsis
# TODO Réfléchir encore à la pertinence de ce choix. Peut-être vaudrait-il
# mieux additionner toutes les notes, même si ce total peut être inférieur à
# des notes de synopsis non présélectionnés
def note_prix
  # evaluation_totale&.note_prix || 'NC'
  evaluation_totale&.note || 'NC'
end

# Note (?) exprimée en pourcentage
def pourcentage
  evaluation&.pourcentage || 'NC'
end

def pourcentage_total
  evaluation_totale&.pourcentage || 'NC'
end

# ---------------------------------------------------------------------
#
#   Méthodes d'helper
#
# ---------------------------------------------------------------------

def formated_note
  @formated_note ||= formate_note(note)
end

def formated_note_totale
  @formated_note_totale ||= formate_note(note_totale)
end

def formated_pourcentage
  @f_pourcentage ||= "#{pourcentage} %"
end #/ formated_pourcentage

def formated_all_pourcentages
  @fallpourcentage ||= "#{pourcentage_total} %"
end #/ formated_all_pourcentages

# IN    {Symbol} Une catégorie (p.e. :coherence, :personnages, :intrigues)
# OUT   {String} La note à afficher
def fnote_categorie(cate)
  formate_note(evaluation&.note_categorie(cate) || 'NC')
end #/ note_categorie

# ---------------------------------------------------------------------
#
#   Méthodes privées
#
# ---------------------------------------------------------------------


  # Retourne :
  #   la liste Array
  #       DES chemins d'accès aux FICHIERS D'ÉVALUATION du synopsis
  #   OU
  #       DU chemin d'accès AU FICHIER D'ÉVALUATION
  #       DU membre du jury options[:evaluator].
  #
  # Note : dans tous les cas, c'est une liste qui est retournée.
  def score_paths_for(options)
    ktype = options[:prix] ? 'prix' : 'pres'
    owner = options[:evaluator] ? options[:evaluator].id : '*'
    tempname = "evaluation-#{ktype}-#{owner}.json"
    Dir["#{folder}/#{tempname}"]
  end #/ score_paths_for
end #/EvaluationMethodsModule
