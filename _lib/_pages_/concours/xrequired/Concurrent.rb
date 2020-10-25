# encoding: UTF-8
# frozen_string_literal: true

class HTML

  attr_accessor :concurrent

  # IN    required  Si TRUE, il faut vraiment qu'on puisse reconnecter un
  #                 concurrent, sinon on renvoie le visiteur vers l'identifi-
  #                 cation. Si required est false, peu importe qu'on puisse en
  #                 reconnecter un.
  # DO    Reconnecte le concurrent s'il est trouvé.
  #
  def try_reconnect_concurrent(required = false)
    if session['concours_user_id'].nil? && not(user.guest?)
      # Connecter un icarien qui fait le concours pour la première fois
      dc = db_exec("SELECT concurrent_id FROM #{DBTBL_CONCURRENTS} WHERE mail = ?", [user.mail]).first
      unless dc.nil?
        session['concours_user_id'] = dc[:concurrent_id]
        db_exec("UPDATE #{DBTBL_CONCURRENTS} SET session_id = ? WHERE concurrent_id = ?", [session.id, dc[:concurrent_id]])
      end
    end

    if session['concours_user_id']
      self.concurrent = Concurrent.authentify(session['concours_user_id'])
      if self.concurrent
        log("RECONNEXION CONCURRENT #{concurrent.id} (#{concurrent.pseudo})")
      end
    elsif required
      erreur(ERRORS[:concours_login_required])
      return redirect_to("concours/identification")
    end
  end #/ try_reconnect_concurrent
end

class Concurrent
  include FemininesMethods
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self
  def get(concurrent_id)
    table_concurrents[concurrent_id]
  end #/ get

  # Pour authentifier le concurrent d'identifiant +concurrent_id+. Son ID
  # de session doit correspondre à la session courante
  def authentify(concurrent_id)
    log("Tentative d'authentification de #{concurrent_id}")
    log("Session ID courant : #{session.id}")
    cand = get(concurrent_id)
    log("Candidat.data : #{cand.data.inspect}")
    log("Session enregistrée : #{cand.session_id.inspect}")
    log("Participe au concours courant ? #{cand.current?.inspect}")
    if cand.session_id == session.id
      return cand
    else
      session.delete('concours_user_id')
    end
  end #/ authentify
  def table_concurrents
    @table_concurrents ||= begin
      h = {}
      db_exec("SELECT * FROM #{DBTBL_CONCURRENTS}").each do |dc|
        conc = new(dc)
        conc.data = dc
        h.merge!( dc[:concurrent_id] => conc)
      end ; h
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

def concurrent_id; @concurrent_id end #/ concurrent_id
alias :id :concurrent_id

def folder
  @folder ||= File.join(CONCOURS_DATA_FOLDER, id)
  # Note : ne pas le créer ici
end #/ folder
# === Options ===
#   (ou "specs")
#
#   bit 0     1 si le concurrent veut recevoir des informations par mail
#   bit 1     1 si le concurrent veut recevoir sa fiche de lecture.
#   bit 2     1 si le concurrent est un icarien
#
def options
  @options ||= data[:options]
end #/ options

def data_current_concours
  @data_current_concours ||= begin
    db_exec(REQUEST_DATA_CONCURRENT_CURRENT_CONCOURS, [id, ::Concours.annee_courante]).first
  end
end #/ data_current_concours

# Retourne la liste Array des données des concours faits par le concurrent
def concours
  @concours ||= Concours.new(self)
end #/ concours

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
  log("data_current_concours: #{data_current_concours.inspect}")
  data_current_concours[:specs][bit].to_i
end #/ spec
def set_spec(bit, value)
  opts = data_current_concours[:specs].dup
  opts[bit] = value.to_s
  data_current_concours[:specs] = opts
end #/ set_spec
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
alias :concurrent? :current?

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

def icarien?
  (@is_icarien ||= begin
    option(2) == 1 ? :true : :false
  end) == :true
end #/ icarien?

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
    spec(0) == 1 ? :true : :false
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
    def specs
      @specs ||= data[:specs]
    end #/ options
  end #/Concours


end #/Concurrent

# Requête pour récupérer toutes les données d'un concurrent
REQUEST_DATA_CONCURRENT = <<-SQL
SELECT
  cc.*,
  cpc.specs AS specs, -- pour savoir si le projet est envoyé
  cpc.titre
  FROM concours_concurrents cc
  INNER JOIN concurrents_per_concours cpc ON cpc.concurrent_id = cc.concurrent_id
  WHERE cc.concurrent_id = ? AND cc.session_id = ?
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
