# encoding: UTF-8
# frozen_string_literal: true

# Requête pour récupérer toutes les données d'un concurrent
REQUEST_DATA_CONCURRENT = <<-SQL
SELECT
  cc.*,
  cpc.specs AS specs, -- pour savoir si le projet est envoyé
  cpc.titre
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cpc.concurrent_id = cc.concurrent_id
  WHERE cc.concurrent_id = ? AND cc.session_id = ? AND cpc.annee = ?
SQL

# Requête SQL pour fixer la demande ou non de la fiche de lecture
REQUEST_UPDATE_OPTIONS = "UPDATE #{DBTABLE_CONCURRENTS} SET options = ? WHERE concurrent_id  = ?"

class HTML
  attr_reader :concurrent
end

class Concurrent
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :concurrent_id, :session_id
def initialize(ini_data)
  @concurrent_id  = ini_data[:concurrent_id]
  @concurrent_id ||= raise("Initialisation impossible sans numéro d'inscription.")
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
alias :patronyme :pseudo

def mail
  @mail ||= data[:mail]
end #/ mail

def concurrent_id; @concurrent_id end #/ concurrent_id
alias :id :concurrent_id

# === Options ===
#   (ou "specs")
#
#   bit 0     1 si le concurrent veut recevoir des informations par mail
#   bit 1     1 si le concurrent veut recevoir sa fiche de lecture.
#
def options
  @options ||= data[:options]
end #/ options

# Retourne la liste Array des données des concours faits par le concurrent
def concours
  @concours ||= Concours.new(self)
end #/ concours

# Retourne la valeur {Integer} de l'option de bit +bit+
#
def option(bit)
  data[:options][bit].to_i
end #/ option
def set_option(bit, value)
  opts = data[:options].dup
  opts[bit] = value
  data[:options] = opts
end #/ set_option

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
    option(1) == 1 ? :true : :false
  end) == :true
end #/ fiche_lecture?

# Retourne TRUE si le concurrent veut recevoir des informations sur
# le concours.
def warned?
  (@is_warned ||= begin
    option(0) == 1 ? :true : :false
  end) == :true
end #/ warned?

# Retourne TRUE si le dossier de participation a été transmis
# Deux conditions :
#   - la propriété dossier_complete dans la DB est à 1
#   - le fichier physique existe
def dossier_transmis?
  (@dossier_transmis ||= begin
    data[:specs][0] == "1" ? :true : :false
  end) == :true
end #/ dossier_complete?

# ---------------------------------------------------------------------
#
#   Méthodes de changement des données
#
# ---------------------------------------------------------------------

def change_pref_fiche_lecture(recevoir)
  set_option(1, recevoir ? '1' : '0')
  update_options
  @fiche_lecture = nil
end #/ change_pref_fiche_lecture

def change_pref_warn_information(recevoir)
  set_option(0, recevoir ? '1' : '0')
  update_options
  @is_warned = nil
end #/ change_pref_warn_information

def update_options
  db_exec(REQUEST_UPDATE_OPTIONS, [options, concurrent_id])
end #/ update_options

  # ---------------------------------------------------------------------
  #
  #   Pour la donnée concours du concurrent
  #
  # ---------------------------------------------------------------------
  class Concours
    def initialize(concurrent)
      @concurrent = concurrent
    end #/ initialize
    def data
      @data ||= begin
        db_exec("SELECT * FROM #{DBTBL_CONCURS_PER_CONCOURS} WHERE concurrent_id = ? AND annee = ?", [self.id, ANNEE_CONCOURS_COURANTE]).first
      end
    end #/ data

    # *** Options pour le concours courant ***
    #     (pas les options générales)
    #
    # bit 0   1 si le projet a été envoyé
    # ...
    # bit 7
    def options
      @options ||= data[:options]
    end #/ options
  end #/Concours


end #/Concurrent
