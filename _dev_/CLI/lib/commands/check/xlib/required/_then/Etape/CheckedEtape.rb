# encoding: UTF-8
# frozen_string_literal: true
class CheckedEtape < ContainerClass
include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des icetapes ou de l'icetape +eid+
  #
  def check(eid = nil)
    (eid.nil? ? alletapes.values : [get(eid)]).each { |m| m.check }
  end #/ check

  def alletapes
    @alletapes ||= begin
      h = {}
      db_exec("SELECT * FROM icetapes ORDER BY created_at ASC").each do |de|
        icetape = instantiate(de)
        h.merge!(icetape.id => icetape)
      end; h
    end
  end #/ alletapes

  # Retourne TRUE si l'icetape d'identifiant +eid+ existe.
  def exists?(eid)
    alletapes.key?(eid)
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

def ref
  @ref ||= "icetape ##{id}"
end #/ ref

#   # Son étape absolue est définie
#   absetape_id_defined
#   # Son étape absolue existe
#   abs_etape_exists
#   # Son propriétaire est défini ?
#   user_id_defined
#   # Son propriétaire existe ?
#   owner_exists
#   # Le module icarien est défini
#   icmodule_id_defined
#   # Le module icarien existe
#   icmodule_exists
#   # Le module icarien a le même propriétaire
#   module_and_etape_same_owner
#   # Si ce n'est pas la dernière étape, sa date de fin doit être définie TODO
#   date_fin_defined_if_not_last_etape
#   # OK
#   mark_success
#   return true
# rescue DataCheckedError => e
#   mark_failure
#   puts e.full_message.rouge
#   return false
# end #/ check



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
  result(CheckedModule.exists?(icmodule_id), :icmodule_exists, [icmodule_id])
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
    CheckedModule.get(icmodule_id) unless icmodule_id.nil?
  end
end #/ icmodule

def la_chose
  @la_chose ||= "l'étape icarien"
end #/ la_chose


def next_etape
  @next_etape ||= icmodule.next_etape_for(self)
end #/ next_etape

# ---------------------------------------------------------------------
#
#   Méthodes de réparation
#
# ---------------------------------------------------------------------

# Méthode appelée pour réparer la propriété :ended_at non définie
def reparer_ended_at
  adate = next_etape&.started_at || expected_end || (created_at.to_i + 4.days)
  set(ended_at: adate.to_s)
end #/ reparer_ended_at

# Retourne un message de succès si on peut réparer le statut de l'étape,
# sinon return false
# On regarde l'état des documents de l'étape. L'idée est que si tous les
# documents sont déposés dans le QDD (6) ou même si leur partage est défini (7)
def can_reparer_status?
  new_statut_possible ? "La réparation peut mettre le statut à #{new_statut_possible}" : false
end #/ can_reparer_status?

def reparer_status(options = nil)
  set(status: new_statut_possible(options))
end #/ reparer_status

def new_statut_possible(options)
  @new_statut_possible = calc_new_statut(options) if @new_statut_possible === nil || not(options.nil?)
  @new_statut_possible
end

def calc_new_statut(options)
  if options && options[:any]
    # Calcul du statut possible, n'importe quelle valeur
    raise "Il faut calculer"
  else
    # Calcul du statut possible entre 7 ou 6
    status_can_be = 7
    icdocuments.each do |icdocument|
      if icdocument[0] == '1'
        # Si le partage n'a pas été défini pour ce document original qui existe,
        # on aura un status possible forcément de 6 seulement
        status_can_be = 6 if icdocument[4] == '0'
        # Si le document original n'a pas été déposé sur le QDD, on ne peut pas
        # réparer le statut
        if icdocument.options[3] == '0'
          status_can_be = nil
          break
        end
      end
      if icdocument[8] == '1'
        # Si le partage n'a pas été défini pour le document commentaires qui
        # existe, on aura un status possible forcément de 6 seulement
        status_can_be = 6 if icdocument[12] == '0'
        # Si le document commentaires qui existe n'a pas été déposé sur le
        # QDD, on ne peut pas updater le statut.
        if icdocument.options[11] == '0'
          status_can_be = nil
          break
        end
      end
      break if status_can_be.nil?
    end
  end
  status_can_be
end #/ new_statut_possible



# ---------------------------------------------------------------------
#
#   Méthode de condition
#
# ---------------------------------------------------------------------

def last?
  (@is_last_etape ||= begin
    icmodule.icetape_id == id ? :true : :false
  end) == :true
end #/ last_etape?

def has_icmodule_id
  (@it_has_icmodule_id ||= begin
    icmodule_id.nil? ? :false : :true
  end) == :true
end #/ has_icmodule_id

def has_absetape_id
  (@it_has_absetape_id ||= begin
    absetape_id.nil? ? :false : :true
  end) == :true
end #/ has_absetape_id

def has_status
  (@it_has_status ||= begin
    status.nil? ? :false : :true
  end) == :true
end #/ has_status

def is_not_last_etape
  (@it_is_not_last_etape ||= begin
    last? ? :true : :false
  end) == :true
end #/ is_not_last_etape

# Retourne true si l'étape est la dernière (icetape_id) du module courant
# (icmodule_id de l'user)
def is_current_etape_of_current_module
  (@it_is_current_etape_of_current_module ||= begin
    (icmodule.courant? && icmodule.icetape_id == id) ? :true : :false
  end) == :true
end #/ is_current_etape_of_current_module

end #/CheckedEtape
