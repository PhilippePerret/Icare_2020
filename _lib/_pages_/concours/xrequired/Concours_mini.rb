# encoding: UTF-8
# frozen_string_literal: true

class Concours
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
def current
  @current ||= new(annee_courante)
end #/ current
def annee_courante
  @annee_courante ||= begin
    Time.now.month < 11 ? Time.now.year : Time.now.year + 1
  end
end #/ annee_courante

# OUT   Boite à coller en bas de la page pour rejoindre le concours
def pub_box
  @pub_box ||= begin
    <<-HTML
<a id="annonce" class="overbox" href="concours/accueil">
  <span>Concours #{annee_courante}</span>
  <span class="spacer">de synopsis</span>
</a>
  HTML
  end
end #/ pub_box

def table
  @table ||= "concours"
end #/ table

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :annee
def initialize(annee, data = nil)
  @annee = annee
  @data  = data
end #/ initialize
# Table des concours
def dbtable; @dbtable ||= self.class.table end
def data
  @data ||= begin
    # Particulariré de cette propriété : si le concours n'existe pas pour
    # l'année demandée, on crée sa donnée
    if db_count(dbtable, {annee: annee}) == 0
      # db_compose_insert(dbtable, data_default.dup) # trop risqué (+ data_default n'existe pas ici)
      {phase:0,annee:0}
    else
      db_get(dbtable, {annee: annee})
    end
  end
end #/ data

# ---------------------------------------------------------------------
#
#   Property
#
# ---------------------------------------------------------------------
def phase;   @phase   ||= data[:phase]   end

# Helper pour indiquer l'échéance, avec le nombre de jours restants
def h_echeance
  @h_echeance ||= formate_date(Time.new(self.class.annee_courante, 3, 2), {duree: true})
end #/ h_echeance

# Phase de dépôt des fichiers de candidature
def phase1?; phase == 1 end
def phase2?; phase == 2 end
def phase3?; phase == 3 end

# Retourne TRUE is le concours est démarré
def started?
  phase > 0
end #/ started?

end #/Concours
