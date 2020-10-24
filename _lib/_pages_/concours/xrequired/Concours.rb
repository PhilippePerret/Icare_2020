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
def initialize(annee, data = nil)
  @annee = annee
  @data  = data
end #/ initialize
def data
  @data ||= begin
    # Particulariré de cette propriété : si le concours n'existe pas pour
    # l'année demandée, on crée sa donnée
    if db_count(DBTBL_CONCOURS, {annee: annee}) == 0
      db_compose_insert(DBTBL_CONCOURS, data_default.dup)
    end
    db_get(DBTBL_CONCOURS, {annee: annee})
  end
end #/ data

# ---------------------------------------------------------------------
#
#   Property
#
# ---------------------------------------------------------------------
def theme;  @theme  ||= data[:theme]  end
def theme_d ; @themedesc ||= data[:theme_d] end
def formated_theme_d; eval("%Q(#{theme_d})") end
def step;   @step   ||= data[:step]   end

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
  data[:step] > 0
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
