# encoding: UTF-8
# frozen_string_literal: true
class CheckedUser < ContainerClass
extend CheckClassMethods
include HelpersWritingMethods
class << self

  # # = main =
  # # Méthode principale qui procède au check des utilisateurs
  # # +uid+ Si défini, on ne check que cet utilisateur, sinon, on les check
  # # tous.
  # def check(uid = nil)
  #   (uid.nil? ? all_reduits.values : [get(uid)]).each { |u| u.check }
  # end #/ check

  def exists?(uid)
    all_reduits.key?(uid)
  end #/ exists?

  def get(uid)
    all_reduits[uid]
  end #/ get

  # Tous les icariens (sauf les administrateurs)
  def all_reduits
    @all_reduits ||= begin
      h = {}
      db_exec("SELECT * FROM users WHERE SUBSTRING(options,1,1) = '0'").each do |du|
        next if du[:id] == 9 # Anonyme
        u = new(du[:id]).tap { |u| u.data = du }
        h.merge!(du[:id] => u)
      end
      h
    end
  end #/ all_reduits
  alias :all_instances :all_reduits

  def table
    @table ||= 'users'
  end #/ table


  def ilya6mois
    @ilya6mois ||= Time.ilya(month: 6).to_i
  end #/ ilya6mois

end # /<< self




# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# ---------------------------------------------------------------------
#
#   Méthodes d'Helpers
#   ------------------
#
# ---------------------------------------------------------------------

def ref
  @ref ||= "#{pseudo} (##{id})"
end #/ ref


# ---------------------------------------------------------------------
#
#   Méthodes de données
#   -------------------
#
# ---------------------------------------------------------------------

# Retourne la liste {Array} des modules d'apprentissage de l'icarien
def icmodules
  @icmodules ||= begin
    db_exec("SELECT * FROM icmodules WHERE user_id = ?", [id]).collect do |dm|
      CheckedModule.instantiate(dm)
    end
  end
end #/ icmodules
# Retourne la date la plus vieille pour l'user, toutes données confondues
def oldest_date
  @oldest_date ||= begin
    all_times = []
    ['icmodules','icetapes','icdocuments','paiements'].each do |tbl|
      case tbl
      when 'icmodules', 'icetapes'
        cols = ['ended_at', 'started_at']
      when 'icdocuments'
        cols = ['time_original', 'time_comments']
      else
        cols = []
      end
      cols += ['created_at']
      request = "SELECT #{cols.join(', ')} FROM #{tbl} WHERE user_id = ? ORDER BY #{cols.join(' DESC, ')} DESC LIMIT 10"
      db_exec(request, [id]).each do |dob|
        all_times += dob.collect { |k,v| v.to_i }
      end
    end
    # On retourne la plus grande valeur
    all_times.max
  end
end #/ oldest_date

# ---------------------------------------------------------------------
#
#   Méthodes de conditions
#   ----------------------
#
# Pour les propriétés :condition des CheckCases
# ---------------------------------------------------------------------

# Retourne TRUE si l'icarien n'est pas détruit
def not_destroyed
  options[3] != '1'
end #/ not_destroyed

def is_inactif
  options[16] == '4'
end #/ is_inactif

# Retourne TRUE si l'icarien a un icmodule_id défini
def has_icmodule_id
  icmodule_id != nil
end #/ has_icmodule_id

def has_a_module
  icmodules.count > 0
end #/ has_a_module

# Retourne true si l'icarien a au moins un module démarré (même s'il est
# fini)
def has_a_module_started
  has_a_module && begin
    res = false
    icmodules.each do |icmod|
      if icmod.started_at
        res = true
        break
      end
    end
    res
  end
end #/ has_a_module_started

# ---------------------------------------------------------------------
#
#   Méthode de check
#   ----------------
#
# ---------------------------------------------------------------------

# Retourne TRUE si la date de sortie de l'user est valide, FALSE dans le
# cas contraire.
# Une date de sortie est valide si :
#   - elle est définie et qu'aucun élément de l'user n'est créé après
#     cette date.
#   - elle n'est pas définie et l'icarien est encore en activité
def date_sortie_valid?
  if date_sortie.nil?
    resultat = icmodule_id != nil
    @error = "date de sortie non définie alors que l'icarien n'est plus en activité." if resultat == false
  elsif not(oldest_date.nil?) # date_sortie définie
    resultat = date_sortie.to_i >= oldest_date
    @error = "date sortie: #{formate_date(date_sortie)} / plus vieille date : #{formate_date(oldest_date)}" if resultat == false
  else
    resultat = false
    @error = "date de sortie non définie (et pas de plus vieille)"
  end
  return resultat
end #/ date_sortie_valid?

# ---------------------------------------------------------------------
#
#   Méthodes de réparation
#   ----------------------
#
# ---------------------------------------------------------------------

def new_date_sortie
  @new_date_sortie ||= begin
    if not(oldest_date.nil?)
      oldest_date.to_s
    elsif updated_at.to_i < self.class.ilya6mois
      updated_at.to_s
    else
      nil
    end
  end
end #/ new_date_sortie

def reparer_date_sortie
  if not(new_date_sortie.nil?)
    set(date_sortie: new_date_sortie.to_s)
    return true
  else
    :reparation_manuelle
  end
end #/ reparer_date_sortie

end #/CheckedUser
