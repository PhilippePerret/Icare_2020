# encoding: UTF-8
# frozen_string_literal: true
class CheckedModule < ContainerClass
include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des icmodules ou de l'icmodule +mid+
  #
  def check(mid = nil)
    (mid.nil? ? allmodules.values : [get(mid)]).each { |m| m.check }
  end #/ check

  def allmodules
    @allmodules ||= begin
      h = {}
      db_exec("SELECT * FROM icmodules ORDER BY created_at ASC").each do |dmodule|
        icmodule = instantiate(dmodule)
        h.merge!(icmodule.id => icmodule)
      end;h
    end
  end #/ allmodules

  def exists?(mid)
    allmodules.key?(mid)
  end #/ exists?

  def table
    @table ||= 'icmodules'
  end #/ table
end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------


def ref
  @ref ||= "IcModule ##{id}"
end #/ ref

# ---------------------------------------------------------------------
#
#   Méthodes de check
#
# ---------------------------------------------------------------------

def absmodule_defined
  result(not(absmodule_id.nil?), :absmodule_required)
end #/ absmodule_defined

def absmodule_exists
  result(AbsModule.exists?(absmodule_id), :absmodule_exists, [absmodule_id])
end #/ absmodule_exists

# Vérifie que la fin du module soit marquée si le module est terminé, ou que
# sa fin ne soit pas défini si c'est un module en cours
def state_absmodule_correct
  extras = nil
  if owner.icmodule_id.nil?
    key_check = :module_ended_with_end_time
    if ended_at.nil?
      # Cette situation peut vouloir dire deux choses :
      #   - soit la date de fin du module n'a pas été définie
      #   - soit l'icmodule_id de l'user est mal affecté
      # On peut départager les deux en regardant la date de fin de
      # la dernière étape. Si elle est vieille => Module terminé avec
      # date de fin oubliée. Si elle est assez récente (dans les six mois) =>
      # Il faut régler le icmodule_id du propriétaire

      # Si la date de fin n'est pas définie, il faut essayer de la mettre à
      # la date de la dernière étape
      fin_last_etape = icetapes.last.ended_at || icetapes.last.updated_at
      ilya6fois = Time.now.to_i - (6*30*3600*24)
      if fin_last_etape.to_i > ilya6fois
        # Régler le module en cours pour l'icarien
        key_check = :module_current_not_affected
      else
        # Régler la date de fin pour le module
        # C'est le key_check défini plus haut
      end
      extras = {date:fin_last_etape, id:id, user_id:user_id}
    end
    result(not(ended_at.nil?), key_check, extras)
  else
    if not(ended_at.nil?)

    end
    result(ended_at.nil?, :module_not_ended_not_end_time, {user_id: user_id})
  end
end #/ state_absmodule_correct

# Le module a au moins une étape
def has_one_etape
  result(icetapes.count > 0, :has_one_etape, {id:id, user_id:user_id, nombre:icetapes.count})
end #/ has_one_etape

def finished_if_last_etape_ended
  return if last_etape.ended_at.nil?
  result(not(ended_at.nil?), :finished_if_last_etape_ended)
end #/ finished_if_last_etape_ended

# ---------------------------------------------------------------------
#
#   Méthodes d'helper
#
# ---------------------------------------------------------------------


# ---------------------------------------------------------------------
#
#   Méthodes de données
#
# ---------------------------------------------------------------------

def la_chose
  @la_chose ||= "le module icarien"
end #/ la_chose

# Son module absolu
def absmodule
  @absmodule ||= AbsModule.get(absmodule_id)
end #/ absmodule

# Ses étapes. Un Array où les étapes sont classées dans l'ordre.
def icetapes
  @icetapes ||= begin
    db_exec("SELECT * FROM icetapes WHERE icmodule_id = #{id} ORDER BY created_at ASC").collect do |de|
      CheckedEtape.instantiate(de)
    end
  end
end #/ icetapes

def last_etape
  @last_etape ||= icetapes.last
end #/ last_etape

# Retourne l'étape suivante de l'étape +icetape+ si elle existe
def next_etape_for(icetape)
  icetapes.values.each_with_index do |ice, idx|
    if ice.id == icetape.id
      return icetapes.values[idx+1]
    end
  end
  return nil # non trouvée (normalement, ne peut pas arriver)
end #/ next_etape_for

# ---------------------------------------------------------------------
#
#   Méthodes de condition
#
# Pour la propriété :condition de la définition des CheckCases
# ---------------------------------------------------------------------

def has_absmodule_id
  absmodule_id != nil
end #/ has_absmodule_id

def is_current_module_of_user
  (@is_current_module_of_user ||= begin
    (has_owner && owner.icmodule_id == id) ? :true : :false
  end) == :true
end #/ is_current_module_of_user
def not_current_module_of_user
  not(is_current_module_of_user)
end #/ not_current_module_of_user
alias :courant? :is_current_module_of_user

def is_started
  (@it_is_started ||= begin
    (started_at != nil) ? :true : :false
  end) == :true
end #/ is_started

end #/CheckedModule
