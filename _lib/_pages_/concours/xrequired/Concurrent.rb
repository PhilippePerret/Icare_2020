# encoding: UTF-8
# frozen_string_literal: true

# Requête pour récupérer toutes les données d'un concurrent
REQUEST_DATA_CONCURRENT = <<-SQL
SELECT
  cc.*,
  cpc.dossier_complete, cpc.fiche_required, cpc.titre
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cpc.concurrent_id = cc.concurrent_id
  WHERE cc.concurrent_id = ? AND cc.session_id = ? AND cpc.annee = ?
SQL

# Requête SQL pour fixer la demande ou non de la fiche de lecture
REQUEST_UPDATE_FICHE_REQUIRED = "UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET fiche_required = ? WHERE concurrent_id  = ? AND annee = ?"

class HTML
  attr_reader :concurrent
end

class Concurrent
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent_id, :session_id
def initialize(ini_data)
  @concurrent_id  = ini_data[:concurrent_id]
  @session_id     = ini_data[:session_id]
end #/ initialize
# Pour charger le concurrent depuis la table
# On doit réussir à le faire avec l'ID de session et l'concurrent_id gardé en session
def data
  @data ||= begin
    # Les données du concurrent
    dconcurrent = db_exec(REQUEST_DATA_CONCURRENT, [concurrent_id, session_id, ANNEE_CONCOURS_COURANTE])
    dconcurrent = dconcurrent.first
  end
end #/ load

# ---------------------------------------------------------------------
#
#   Propriétés
#
# ---------------------------------------------------------------------
def pseudo
  @pseudo ||= data[:patronyme]
end #/ pseudo

def concurrent_id
  @concurrent_id ||= data[:concurrent_id]
end #/ concurrent_id
alias :id :concurrent_id

# Retourne la liste Array des données des concours faits par le concurrent
def concours
  @concours ||= db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ?", self.id)
end #/ concours

# ---------------------------------------------------------------------
#
#   Statut
#
# ---------------------------------------------------------------------

# Retourne TRUE pour savoir si le concurrent, identifié par le concurrent_id en
# session et l'identifiant de session fourni existe véritablement dans la
# base de données.
def exists?
  data != nil
end #/ exists?

def femme?
  (@is_femme ||= begin
    data[:sexe] == 'F' ? :true : :false
  end) == :true
end #/ femme?

# Retourne TRUE si le concurrent veut recevoir sa fiche de lecture
def fiche_lecture?
  (@fiche_lecture ||= begin
    data[:fiche_required] == 1 ? :true : :false
  end) == :true
end #/ fiche_lecture?

# Retourne TRUE si le dossier de participation a été transmis
# Deux conditions :
#   - la propriété dossier_complete dans la DB est à 1
#   - le fichier physique existe
def dossier_transmis?
  (@dossier_transmis ||= begin
    data[:dossier_complete] == 1 ? :true : :false
  end) == :true
end #/ dossier_complete?

# ---------------------------------------------------------------------
#
#   Méthodes de changement des données
#
# ---------------------------------------------------------------------

def change_pref_fiche_lecture(recevoir)
  db_exec(REQUEST_UPDATE_FICHE_REQUIRED, [recevoir, concurrent_id, ANNEE_CONCOURS_COURANTE])
  @fiche_lecture = recevoir ? :true : :false
end #/ change_pref_fiche_lecture

end #/Concurrent
