# encoding: UTF-8
# frozen_string_literal: true
require_relative 'module_helpers'
class CheckedModules < ContainerClass
  include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des icmodules
  #
  def check
    puts "=== Check des IcModules ===".bleu
    IcareCLI.verbose = true if IcareCLI.option?(:infos)
    db_exec("SELECT * FROM icmodules ORDER BY created_at ASC").each_with_index do |dmodule, idx|
      icmodule = instantiate(dmodule)
      icmodule.check
      break if idx > 3
      IcareCLI.verbose = false if idx < 1 && IcareCLI.option?(:infos)
    end

  end #/ check

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
  header
  # Son propriétaire est défini ?
  user_id_defined || raise(DataCheckedError.new(:owner_required))
  # Son propriétaire existe ?
  owner_exists || raise(DataCheckedError.new(:owner_unknown, [user_id]))
  # Son identifiant de module absolu est défini
  absmodule_defined || raise(DataCheckedError.new(:absmodule_id_required))
  # Son module absolu existe
  absmodule_exists || raise(DataCheckedError.new(:absmodule_unknown, [absmodule_id]))
  # Son état (fini ou non) est le bon
  state_absmodule_correct || raise(DataCheckedError.new(:module_bad_end_state, [@current_error]))
  # Il a au moins une étape TODO
  has_one_etape || raise(DataCheckedError.new(:one_etape_required))
  mark_success
rescue DataCheckedError => e
  mark_failure
  puts e.message.rouge
end #/ check

# ---------------------------------------------------------------------
#
#   Méthodes de check
#
# ---------------------------------------------------------------------
def user_id_defined
  result(not(user_id.nil?), "La propriété user_id est définie")
end #/ user_id_defined

def owner_exists
  result(User.exists?(user_id), "L'user ##{user_id} existe")
end #/ owner_exists

def absmodule_defined
  result(not(absmodule_id.nil?), "Le module absolu est défini")
end #/ absmodule_defined

def absmodule_exists
  result(AbsModule.exists?(absmodule_id), "Le module absolu ##{absmodule_id} existe.")
end #/ absmodule_exists

# Vérifie que la fin du module soit marquée si le module est terminé, ou que
# sa fin ne soit pas défini si c'est un module en cours
def state_absmodule_correct
  if owner.icmodule_id.nil?
    if ended_at.nil?
      @current_error = "le module est terminé, mais sa date de fin n'est pas définie."
    end
    result(not(ended_at.nil?), "Le module est terminé et sa date de fin est bien définie.")
  else
    if not(ended_at.nil?)
      @current_error = "le module n'est pas terminé, mais sa date de fin est définie."
    end
    result(ended_at.nil?, "Le module est en cours, pas de date de fin définie.")
  end
end #/ state_absmodule_correct

# Le module a au moins une étape
def has_one_etape
  result(icetapes.count > 0, "Le module a au moins une étape (il en a #{icetapes.count})")
end #/ has_one_etape



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
#   Méthodes de données
#
# ---------------------------------------------------------------------

def la_chose
  @la_chose ||= "le module icarien"
end #/ la_chose

# Son module absolu
def absmodule
  @absmodule ||= AbsModule.get(abs_module_id)
end #/ absmodule

# Ses étapes. Un Array où les étapes sont classées dans l'ordre.
def icetapes
  @icetapes ||= begin
    db_exec("SELECT * FROM icetapes WHERE icmodule_id = #{id} ORDER BY created_at ASC").collect do |de|
      CheckedEtapes.instantiate(de)
    end
  end
end #/ icetapes

end #/CheckedModules
