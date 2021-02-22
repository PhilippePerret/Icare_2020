# encoding: UTF-8
# frozen_string_literal: true
require_relative './Concours_mini'
require_relative './constants'

class HTML
  attr_reader :concours
end


class Concours
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  # L'évaluateur courant
  # (pour le moment, c'est l'user connecté, plus tard, ce sera une
  #  classe spéciale qui devra au moins répondre à la méthode :id)
  def evaluator
    user
  end

  # Retourne TRUE si concours arrive à proximité de l'échéance de dépôt des
  # fichier, c'est-à-dire 2 jours avant
  def proche_echeance?
    (date_echeance.to_i - Time.now.to_i) < 2.days
  end

  def date_echeance
    @date_echeance ||= Time.new(ANNEE_CONCOURS_COURANTE, 3, 1, 24, 0, 0)
  end #/ date_echeance
end # / << self

# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
#
#   Property
#
# ---------------------------------------------------------------------
def theme;  @theme  ||= data[:theme]  end
def theme_d ; @themedesc ||= data[:theme_d] end
def formated_theme_d; eval("%Q(#{theme_d})") end

def prix1
  @prix1 ||= data[:prix1]
end
def formated_prix1
  @formated_prix1 ||= eval("%Q(#{prix1})")
end
def prix2
  @prix2 ||= data[:prix2]
end
def formated_prix2
  @formated_prix2 ||= eval("%Q(#{prix2})")
end
def prix3
  @prix3 ||= data[:prix3]
end
def formated_prix3
  @formated_prix3 ||= eval("%Q(#{prix3})")
end

# La modifier dans le fichier secret 'concours.rb'
def jury_members
  @jury_members ||= begin
    require './_lib/data/secret/concours'
    CONCOURS_DATA[:evaluators]
  end
end #/ jury_members
alias :jury :jury_members

def jury1
  @jury1 ||= jury_members.select { |dc| dc[:jury] != 2 }
end

def jury2
  @jury2 ||= jury_members.select { |dc| dc[:jury] == 2 }
end

# ---------------------------------------------------------------------
#
#   Propriétés publiques
#
# ---------------------------------------------------------------------
def nombre_concurrents
  @nombre_concurrents ||= db_count(DBTBL_CONCURS_PER_CONCOURS, {annee: annee})
end #/ nombre_concurrents

def nombre_synopsis_conformes
  @nombre_synopsis_conformes ||= db_count(DBTBL_CONCURS_PER_CONCOURS, "annee = #{annee} AND SUBSTRING(specs,2,1) = 1")
end #/ nombre_synopsis_conformes

# ---------------------------------------------------------------------
#
#   Dates et helpers de date
#
# ---------------------------------------------------------------------
def date_lancement
  @date_lancement ||= Time.new(annee - 1, 11, 1)
end #/ date_lancement

def date_echeance
  @date_echeance ||= Time.new(annee, 3, 1)
end #/ date_echeance

def date_fin_preselection
  @date_preselection ||= Time.new(annee, 4, 15)
end #/ date_preselection

def date_palmares
  @date_palmares ||= Time.new(annee, 6, 1)
end #/ date_palmares

end #/Concours
