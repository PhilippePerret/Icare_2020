# encoding: UTF-8
# frozen_string_literal: true
class CheckedEtapes < ContainerClass
  include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des IcEtapes
  #
  def check
    puts "=== Check des IcEtapes ===".bleu
    IcareCLI.verbose = true if IcareCLI.option?(:infos)
    db_exec("SELECT * FROM icetapes ORDER BY created_at ASC").each_with_index do |de, idx|
      icetape = instantiate(de)
      resultat = icetape.check
      if !resultat && IcareCLI.option?(:fail_fast)
        return false
      end
      # break if idx > 2
      IcareCLI.verbose = false if idx < 1 && IcareCLI.option?(:infos)
    end
    return true
  end #/ check

  def exists?(mid)
    get(mid) != nil
  end #/ exists?

  def table
    @table ||= 'icetapes'
  end #/ table

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# = main =
#
# Méthode d'instance principale de check de l'étape icarien
def check
  DataCheckedError.current_owner = self
  header
  # Son étape absolue est définie
  absetape_id_defined
  # Son étape absolue existe
  abs_etape_exists
  # Son propriétaire est défini ?
  user_id_defined
  # Son propriétaire existe ?
  owner_exists
  # Le module icarien est défini
  icmodule_id_defined
  # Le module icarien existe
  icmodule_exists
  # Le module icarien a le même propriétaire
  module_and_etape_same_owner
  # Si ce n'est pas la dernière étape, sa date de fin doit être définie TODO
  date_fin_defined_if_not_last_etape
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
    m = ["Étape icarien icetapes##{id} “#{absetape&.numero}. #{absetape.titre}”"]
    m << " (owner: #{owner.pseudo} (##{owner.id}))" unless owner.nil?
    m.join('')
  end
end #/ inspect

# ---------------------------------------------------------------------
#
#   Méthodes de check
#
# ---------------------------------------------------------------------

def absetape_id_defined
  result(not(absetape_id.nil?), :absetape_id_required)
end #/ absetape_id_defined

def abs_etape_exists
  result(AbsEtape.exists?(absetape_id), :absetape_exists, [absetape_id])
end #/ abs_etape_exists

def icmodule_id_defined
  result(not(icmodule_id.nil?), :icmodule_id_required)
end #/ icmodule_id_defined

def icmodule_exists
  result(CheckedModules.exists?(icmodule_id), :icmodule_exists, [icmodule_id])
end #/ icmodule_exists

def module_and_etape_same_owner
  result(user_id && icmodule.user_id == user_id, :module_and_etape_same_owner, [icmodule.user_id, user_id])
end #/ module_and_etape_same_owner

def date_fin_defined_if_not_last_etape
  return if last? && icmodule.courant?
  precisions = [last? ? "c'est la dernière étape" : "ce n'est pas la dernière étape"]
  precisions << (icmodule.courant? ? "c'est le module courant" : "ce n'est pas le module courant")
  result(not(ended_at.nil?), :date_fin_defined_if_not_last, precisions)
end #/ date_fin_defined_if_not_last_etape

# ---------------------------------------------------------------------
#
#   Méthodes d'helper
#
# ---------------------------------------------------------------------

def header
  STDOUT.write "Check de l’étape icarien ##{id}#{IcareCLI.verbose? ? RC : ''}"
end #/ header

# ---------------------------------------------------------------------
#
#   Méthodes de données
#
# ---------------------------------------------------------------------

def absetape
  @absetape ||= begin
    AbsEtape.get(absetape_id) unless absetape_id.nil?
  end
end #/ absetape

def icmodule
  @icmodule ||= begin
    CheckedModules.get(icmodule_id) unless icmodule_id.nil?
  end
end #/ icmodule

def last?
  @is_last_etape ||= begin
    icmodule.icetape_id == id ? :true : :false
  end
  @is_last_etape == :true
end #/ last_etape?

def la_chose
  @la_chose ||= "l'étape icarien"
end #/ la_chose

end #/CheckedEtapes
