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
  end #/ evaluator
end # / << self
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
end #/ prix1
def formated_prix1
  @formated_prix1 ||= eval("%Q(#{prix1})")
end #/ formated_prix1
def prix2
  @prix2 ||= data[:prix2]
end #/ prix2
def formated_prix2
  @formated_prix2 ||= eval("%Q(#{prix2})")
end #/ formated_prix2
def prix3
  @prix3 ||= data[:prix3]
end #/ prix3
def formated_prix3
  @formated_prix3 ||= eval("%Q(#{prix3})")
end #/ formated_prix3

# La modifier dans le fichier secret 'concours.rb'
def jury_members
  @jury_members ||= begin
    require './_lib/data/secret/concours'
    CONCOURS_DATA[:evaluators]
  end
end #/ jury_members
alias :jury :jury_members

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

# # ---------------------------------------------------------------------
# #   CONFIGURATION
# #   (OBSOLETE)
# # ---------------------------------------------------------------------
# def config
#   @config ||= begin
#     h = {}
#     JSON.parse(File.read(config_path)).each do |k,v|
#       h.merge!(k.to_sym => v)
#     end ; h
#   end
# end #/ config
#
# def config_path
#   @config_path ||= File.expand_path(File.join('.','_lib','_pages_','concours','xrequired','config.json'))
# end #/ config_path

end #/Concours
