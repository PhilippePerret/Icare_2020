# encoding: UTF-8
# frozen_string_literal: true
class CheckedModules < ContainerClass
  include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des icmodules
  #
  def check

    # return # pour faire les suivants TODO SUPPRIMER QUAND FINI

    puts "=== Check des IcModules ===".bleu
    IcareCLI.verbose = true if IcareCLI.option?(:infos)
    db_exec("SELECT * FROM icmodules ORDER BY created_at ASC").each_with_index do |dmodule, idx|
      icmodule = instantiate(dmodule)
      resultat = icmodule.check
      if !resultat && IcareCLI.option?(:fail_fast)
        return false
      end
      # break if idx > 3
      IcareCLI.verbose = false if idx < 1 && IcareCLI.option?(:infos)
    end
    return true
  end #/ check

  def exists?(mid)
    get(mid) != nil
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

# = main =
# Check principal DU module
def check
  DataCheckedError.current_owner = self
  header
  # Son propriétaire est défini ?
  user_id_defined
  # Son propriétaire existe ?
  owner_exists
  # Son identifiant de module absolu est défini
  absmodule_defined
  # Son module absolu existe
  absmodule_exists
  # Son état (fini ou non) est le bon
  state_absmodule_correct
  # Il a au moins une étape
  has_one_etape
  # Si la dernière étape est fini, le module doit être fini
  finished_if_last_etape_ended
  # N'est pas le module courant s'il est fini TODO
  # OK
  mark_success
  return true
rescue DataCheckedError => e
  mark_failure
  puts e.full_message.rouge
  return false
end #/ check

def inspect
  @inspect ||= begin
    m = "Module Icarien icmodules##{id} “#{absmodule&.name}”"
    unless owner.nil?
      " (owner: #{owner.pseudo} (##{owner.id}))"
    end
  end
end #/ inspect

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

# Entête du check du module
def header
  STDOUT.write "Check du module icarien ##{id}#{IcareCLI.verbose? ? RC : ''}"
end #/ header

# ---------------------------------------------------------------------
#
#   Méthodes d'état
#
# ---------------------------------------------------------------------

# Retourne TRUE si ce module est en cours de travail
def courant?
  owner.icmodule_id == id
end #/ courant?

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
      CheckedEtapes.instantiate(de)
    end
  end
end #/ icetapes

def last_etape
  @last_etape ||= icetapes.last
end #/ last_etape

end #/CheckedModules
