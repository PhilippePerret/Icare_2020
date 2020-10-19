# encoding: UTF-8
# frozen_string_literal: true
class HTML
  attr_reader :concours
end


class Concours
class << self
  attr_accessor :current # le concours courant
  def current
    @current ||= new(ANNEE_CONCOURS_COURANTE)
  end #/ current
end # /<< self
attr_reader :annee
def initialize(annee)
  @annee = annee
end #/ initialize
def data
  @data ||= db_get(DBTABLE_CONCOURS, {annee: annee})
end #/ data

# ---------------------------------------------------------------------
#
#   Property
#
# ---------------------------------------------------------------------
def theme
  @theme ||= data[:theme]
end #/ theme
def prix1
  @prix1 ||= data[:prix1]
end #/ prix1
def prix2
  @prix2 ||= data[:prix2]
end #/ prix2
def prix3
  @prix3 ||= data[:prix3]
end #/ prix3

# ---------------------------------------------------------------------
#
#   Propriétés volatiles
#
# ---------------------------------------------------------------------
def nombre_concurrents
  @nombre_concurrents ||= db_count(DBTBL_CONCURS_PER_CONCOURS, {annee: annee})
end #/ nombre_concurrents

# Helper pour indiquer l'échéance, avec le nombre de jours restants
def h_echeance
  @h_echeance ||= formate_date(Time.new(ANNEE_CONCOURS_COURANTE, 3, 1), {duree: true})
end #/ h_echeance

# ---------------------------------------------------------------------
#
#   STATUTS
#
# ---------------------------------------------------------------------
# Retourne TRUE is le concours est démarré
def started?
  config[:started] == true
end #/ started?

# ---------------------------------------------------------------------
#
#   CONFIGURATION
#
# ---------------------------------------------------------------------
def config
  @config ||= begin
    h = {}
    JSON.parse(File.read(config_path)).each do |k,v|
      h.merge!(k.to_sym => v)
    end ; h
  end
end #/ config

def config_path
  @config_path ||= File.expand_path(File.join('.','_lib','_pages_','concours','xrequired','config.json'))
end #/ config_path

end #/Concours
