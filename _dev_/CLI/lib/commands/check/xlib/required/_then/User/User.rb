# encoding: UTF-8
# frozen_string_literal: true
class CheckedUser < ContainerClass
class << self

  # = main =
  # Méthode principale qui procède au check des utilisateurs
  # +uid+ Si défini, on ne check que cet utilisateur, sinon, on les check
  # tous.
  def check(uid = nil)
    (uid.nil? ? all_reduits.values : [get(uid)]).each { |u| u.check }
  end #/ check

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
      db_exec("SELECT id, pseudo, mail, icmodule_id, options FROM users WHERE SUBSTRING(options,1,1) = '0'").each do |du|
        u = new(du[:id]).tap { |u| u.data = du }
        h.merge!(du[:id] => u)
      end
      h
    end
  end #/ all_reduits

  def table
    @table ||= 'users'
  end #/ table
end # /<< self




# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# = main =
# Procède au check de l'icarien
def check
  CHECKCASES.each { |cc| CheckCase.new(self, cc).proceed }
end #/ check

def ref
  @ref ||= "#{pseudo} (##{id})"
end #/ ref
# ---------------------------------------------------------------------
#
#   Méthodes de conditions
#
# Pour les propriétés :condition des CheckCases
# ---------------------------------------------------------------------

# Retourne TRUE si l'icarien n'est pas détruit
def not_destroyed
  options[3] != '1'
end #/ not_destroyed

# Retourne TRUE si l'icarien a un icmodule_id défini
def has_icmodule_id
  icmodule_id != nil
end #/ has_icmodule_id

end #/CheckedUser
