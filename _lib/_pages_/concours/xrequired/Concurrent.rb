# encoding: UTF-8
# frozen_string_literal: true
require_relative './constants'
require './_lib/required/__first/feminines'

class Concurrent
  include FemininesMethods
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def get(concurrent_id)
    # log("Concurrent::get(#{concurrent_id}::#{concurrent_id.class})")
    table_concurrents[concurrent_id]
  end #/ get

  # OUT   True si on trouve un concurrent répondant aux paramètres +params+
  # IN    +params+ Table Hash de paramètres définissant le concurrent, en
  #       général son mail (mail: ...)
  def exists?(params)
    db_count(DBTBL_CONCURRENTS, params) > 0
  end #/ exists?

  # IN    Identifiant du concurrent (concurrent_id)
  # OUT   True si le concurrent d'identifiant +cid+ est inscrit à la session
  #       courante du concours. False otherwise.
  def is_current_concurrent?(cid)
    db_count(DBTBL_CONCURS_PER_CONCOURS, {concurrent_id: cid, annee: Concours.current.annee}) > 0
  end

  # Pour authentifier le concurrent d'identifiant +concurrent_id+. Son ID
  # de session doit correspondre à la session courante
  def authentify(concurrent_id)
    cand = get(concurrent_id)
    if cand.session_id == session.id
      return cand
    else
      session.delete('concours_user_id')
      return nil
    end
  end #/ authentify

  def all_current
    @all_current ||= begin
      db_exec(REQUEST_ALL_DATA_CONCURRENTS_CURRENT, [Concours.current.annee]).collect do |dc|
        conc = new(concurrent_id: dc[:concurrent_id])
        conc.set_all_data(dc)
        conc
      end
    end
  end #/ all_current

  def table_concurrents
    @table_concurrents ||= begin
      h = {}
      db_exec("SELECT * FROM #{DBTBL_CONCURRENTS}").each do |dc|
        conc = new(dc)
        conc.data = dc
        h.merge!( dc[:concurrent_id] => conc)
      end ;
      # log("table_concurrents: #{h.inspect}")
      h
    end
  end #/ table_concurrents
end # << self

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

# OUT   Référence au concurrent
def ref
  @ref ||= "#{patronyme} (##{id} - #{mail})"
end #/ ref

# OUT   Les datas minimum du concurrent (pour les mails)
def min_data
  @min_data ||= {pseudo:pseudo, mail:mail, sexe:sexe, id:id}
end #/ min_data

def bind; binding() end

# Quand on charge toutes les données du concurrent pour le concours courant,
# on peut utiliser cette méthode pour définir toutes les données.
#   @data   Ce sont les données du concurrent, hors concours
#   @data_current_concours    Ce sont les données propres au concours courant
def set_all_data(alldata)
  @data = alldata
  @data_current_concours = alldata
end #/ set_all_data

# Pour charger le concurrent depuis la table
# On doit réussir à le faire avec l'ID de session et l'concurrent_id gardé en session
def data
  @data ||= begin
    # Les données du concurrent
    dconcurrent = db_exec(REQUEST_DATA_CONCURRENT, [concurrent_id, session_id])
    dconcurrent = dconcurrent.first
  end
end #/ data
def data=(value); @data = value end

# ---------------------------------------------------------------------
#
#   Propriétés
#
# ---------------------------------------------------------------------
def patronyme ; @patronyme ||= data[:patronyme] end
alias :pseudo :patronyme

def mail ; @mail ||= data[:mail] end
def sexe ; @sexe ||= data[:sexe] end

def concurrent_id; @concurrent_id end #/ concurrent_id
alias :id :concurrent_id

def projet_titre
  @projet_titre ||= data_current_concours[:titre]
end #/ projet_titre

def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER, id)
  # Note : ne pas le créer ici
end
# === Options ===
# Cf. le manuel (icare read/write concours)
#
def options
  @options ||= data[:options]
end #/ options

def data_current_concours
  @data_current_concours ||= begin
    db_exec(REQUEST_DATA_CONCURRENT_CURRENT_CONCOURS, [id, Concours.current.annee]).first
  end
end #/ data_current_concours

# Retourne la liste Array des données des concours faits par le concurrent
def concours
  @concours ||= ConcurrentConcours.new(self)
end #/ concours

# Le synopsis
# Note : l'instance sera "nil" si le synopsis n'existe pas
def synopsis
  @synopsis ||= begin
    html.require_xmodule('synopsis')
    Synopsis.new(id, ANNEE_CONCOURS_COURANTE)
  end
end

def cfile
  @cfile ||= begin
    Concours::CFile.new(self, ANNEE_CONCOURS_COURANTE, synopsis)
  end
end

# Retourne la liste Array de tous les concours du concurrent
def all_concours
  @all_concours ||= begin
    db_exec(REQUEST_ALL_CONCOURS_CURRENT, [id]).collect do |dcon|
      if dcon[:prix]
        dcon[:prix] = "Prix #{dcon[:prix]}"
      else
        dcon[:prix] = "pas de prix"
      end
      dcon # pour collect
    end
  end
end #/ all_concours

# Retourne la valeur {Integer} de l'option de bit +bit+
#
def option(bit)
  data[:options][bit].to_i
end #/ option
def set_option(bit, value)
  opts = data[:options].dup
  opts[bit] = value.to_s
  data[:options] = opts
end #/ set_option

def spec(bit)
  # log("data_current_concours: #{data_current_concours.inspect}")
  data_current_concours[:specs][bit].to_i
end #/ spec
def set_spec(bit, value, options = nil)
  opts = data_current_concours[:specs].dup
  opts[bit] = value.to_s
  data_current_concours[:specs] = opts
  save_specs unless options && options[:no_save]
end #/ set_spec
def specs
  data_current_concours[:specs]
end #/ specs

def save_specs
  db_exec("UPDATE #{DBTBL_CONCURS_PER_CONCOURS} SET specs = ? WHERE concurrent_id = ? AND annee = ?", [data_current_concours[:specs], id, ANNEE_CONCOURS_COURANTE])
end #/ save_specs
# ---------------------------------------------------------------------
#
#   Statut
#
# ---------------------------------------------------------------------

# Retourne TRUE si c'est un concurrent du concours actuel. Sinon, c'est
# un ancien concurrent qui n'est pas encore inscrit
def current?
  not(data_current_concours.nil?)
end #/ current?
# alias :concurrent? :current?

# Retourne true si c'est sa première participation à un concours
def first_concours?
  :TRUE === @is_first_concours ||= all_concours.count == 1 ? :TRUE : :FALSE
end #/ first_concours?

# Retourne TRUE pour savoir si le concurrent, identifié par le concurrent_id en
# session et l'identifiant de session fourni existe véritablement dans la
# base de données.
def exists?
  data != nil
end #/ exists?

def femme?
  :TRUE === @is_femme ||= sexe == 'F' ? :TRUE : :FALSE
end #/ femme?

def icarien?
  :TRUE === @is_icarien ||= option(2) == 1 ? :TRUE : :FALSE
end #/ icarien?

# Retourne TRUE si le concurrent veut recevoir sa fiche de lecture
def fiche_lecture?
  :TRUE === @fiche_lecture ||= option(1) == 1 ? :TRUE : :FALSE
end
alias :want_fiche_lecture? :fiche_lecture?

# Retourne TRUE si le concurrent veut recevoir des informations sur
# le concours.
def warned?
  :TRUE === @is_warned ||= option(0) == 1 ? :TRUE : :FALSE
end

# OUT   True si le concurrent, pour le concours courant, a été présélectionné
def preselected?
  :TRUE === @is_preselected ||= spec(2) == 1 ? :TRUE : :FALSE
end

# OUT   Le prix reçu (1, 2 ou 3) ou nil
def prix
  p = spec(3)
  p = nil if p == 0
  return p
end #/ prix

# ---------------------------------------------------------------------
#
#   Méthodes de changement des données
#
# ---------------------------------------------------------------------

def update_options
  db_exec(REQUEST_UPDATE_OPTIONS, [options, concurrent_id])
end #/ update_options

  # ---------------------------------------------------------------------
  #
  #   Pour la donnée concours du concurrent
  #
  # ---------------------------------------------------------------------
  class ConcurrentConcours
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
    # Valeurs : cf. le mode d'emploi (icare read concours)
    def specs
      @specs ||= data[:specs]
    end #/ options

  end #/class Concurrent::ConcurrentConcours


end #/Concurrent

# Requête pour récupérer toutes les données d'un concurrent
REQUEST_DATA_CONCURRENT = <<-SQL
SELECT
  cc.*,
  cpc.specs AS specs, -- pour savoir si le projet est envoyé
  cpc.titre
  FROM #{DBTBL_CONCURRENTS} cc
  INNER JOIN #{DBTBL_CONCURS_PER_CONCOURS} cpc ON cpc.concurrent_id = cc.concurrent_id
  WHERE cc.concurrent_id = ? AND cc.session_id = ?
SQL

REQUEST_ALL_DATA_CONCURRENTS_CURRENT = <<-SQL
SELECT
  cc.*, cpc.*
  FROM #{DBTBL_CONCURRENTS} cc
  INNER JOIN #{DBTBL_CONCURS_PER_CONCOURS} cpc ON cpc.concurrent_id = cc.concurrent_id
  WHERE cpc.annee = ?
SQL

REQUEST_DATA_CONCURRENT_CURRENT_CONCOURS = <<-SQL
SELECT *
  FROM #{DBTBL_CONCURS_PER_CONCOURS}
  WHERE concurrent_id = ? AND annee = ?
SQL

# Requête SQL pour fixer la demande ou non de la fiche de lecture
REQUEST_UPDATE_OPTIONS = "UPDATE #{DBTBL_CONCURRENTS} SET options = ? WHERE concurrent_id  = ?"

REQUEST_ALL_CONCOURS_CURRENT = <<-SQL
SELECT
  cpc.*,
  c.theme AS theme
  FROM #{DBTBL_CONCURS_PER_CONCOURS} cpc
  INNER JOIN #{DBTBL_CONCOURS} c ON c.annee = cpc.annee
  WHERE cpc.concurrent_id = ?
SQL
