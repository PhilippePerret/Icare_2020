# encoding: UTF-8
# frozen_string_literal: true
class CheckedEtape < ContainerClass
extend CheckClassMethods
include HelpersWritingMethods
class << self

  # # = main =
  # #
  # # Check des icetapes ou de l'icetape +eid+
  # #
  # def check(eid = nil)
  #   (eid.nil? ? alletapes.values : [get(eid)]).each do |m|
  #     m.check || return
  #   end
  #   return true # pour pouvoir poursuivre
  # end #/ check

  def alletapes
    @alletapes ||= begin
      h = {}
      db_exec("SELECT * FROM icetapes ORDER BY created_at ASC").each do |de|
        icetape = instantiate(de)
        h.merge!(icetape.id => icetape)
      end; h
    end
  end #/ alletapes
  alias :all_instances :alletapes

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
#   # Le module icarien a le même propriétaire
#   module_and_etape_same_owner
#   # Si ce n'est pas la dernière étape, sa date de fin doit être définie TODO
#   date_fin_defined_if_not_last_etape


# ---------------------------------------------------------------------
#
#   Méthodes de condition
#
# ---------------------------------------------------------------------


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

# S'assurent que les watchers de l'étape sont cohérents
# En général, il n'y a qu'un seul watcher par étape et il dépend du status
# de l'étape.
def watchers_are_coherents
  dwatchers = WATCHER_WTYPE_PER_STATUS[status]
  if dwatchers[:wtype] && watchers.count == 0
    raise "L’#{ref} devrait posséder au moins 1 watcher."
  end
  if dwatchers[:maybe]
    if watchers.count > 2
      raise "Trop de watchers (#{watchers.count} — 2 maximum pour l’#{ref})"
    end
    if not watchers.key?(dwatchers[:wtype])
      raise "L’#{ref} devrait avoir le watcher 'dwatchers[:wtype]'"
    end
  else
    if watchers.count > 1
      raise "Trop de watchers (#{watchers.count} au lieu de 1 seul)"
    end
    if not watchers.key?(dwatchers[:wtype])
      raise "Le watcher devrait avoir le type '#{dwatchers[:wtype]}', il a le type '#{watchers.values.first[:wtype]}'…"
    end
  end
rescue Exception => e
  @error = e.message
  return false
else
  return true
end #/ watchers_are_coherents

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

def icdocuments
  @icdocuments ||= begin
    h = {}
    db_exec("SELECT * FROM icdocuments WHERE icetape_id = ?", id).each do |dd|
      doc = CheckedDocument.instantiate(dd)
      h.merge!(doc.id => doc)
    end
    h
  end
end #/ icdocuments

# Retourne les données de tous les watchers de l'icétape
# C'est une table qui contient le wtype en clé (entendu qu'il doit être
# unique, pour chaque étape donnée)
def watchers
  @watchers ||= begin
    h = {}
    request = "SELECT * FROM watchers WHERE objet_id = ? AND user_id = ? AND wtype IN ('send_work','download_work','send_comments','changement_etape','download_comments','qdd_depot','qdd_sharing','qdd_coter')"
    db_exec(request, [id, user_id]).each do |dw|
      h.merge!( dw[:wtype] => dw )
    end; h
  end
end #/ watchers

def has_watcher?(wtype)
  watchers.key?(wtype)
end #/ has_watcher?

# ---------------------------------------------------------------------
#
#   Méthodes de check
#
# ---------------------------------------------------------------------

# Méthode qui s'assure que le statut de l'étape de module possède un
# statut cohérent avec ses données.
# Pour le savoir, on se sert de la méthode qui doit aussi servir à la
# réparation et qui renvoie le statut par rapport à l'état de l'étape.
def check_status_value
  resultat = status == status_considering_data
  unless resultat
    if status_considering_data === false
      @error = "impossible de déterminer le statut attendu d'après les données — le statut actuel de l'étape est #{status.inspect}"
    else
      @error = "statut de l'étape : #{status.inspect} / statut d'après les données de l'étape : #{status_considering_data.inspect}"
    end
  end
  return resultat
end #/ check_status_value


# Retourne le statut en fonction des données trouvées
# Algorithme de recherche :
#   On se sert des watchers pour connaitre le statut et l'état des
#   documents à la fin.
def status_considering_data
  if icdocuments.count == 0
    if has_watcher?('send_work')
      1
    else
      false
    end
  else # Il y a des documents ou l'étape n'est pas fini
    if has_watcher?('download_work')
      2
    elsif has_watcher?('send_comments')
      3
    elsif has_watcher?('download_comments')
      4
    elsif has_watcher?('qdd_depot')
      5
    elsif has_watcher?('qdd_sharing')
      6
    elsif documents_sharing_defined?
      7
    else
      false # ça doit provoquer une erreur de réparation manuelle à faire
    end
  end
end #/ status_considering_data



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
  status_considering_data ? "La réparation peut mettre le statut à #{status_considering_data}" : false
end #/ can_reparer_status?

def reparer_status(options = nil)
  set(status: status_considering_data)
end #/ reparer_status

# Retourne TRUE si les documents définissent leur partage
#
# Noter que ces données peuvent être modifiées par la réparation des
# documents. Peut-être qu'il vaut mieux la lancer avant.
def documents_sharing_defined?
  icdocuments.each do |icdocument|
    if icdocument[0] == '1' # si le document original existe (déposé)
      # Si le document original n'a pas été déposé sur le QDD, la partage,
      # forcément, n'est pas défini
      return false if icdocument.options[3] == '0'
      # Si le partage n'a pas été défini pour ce document original qui existe,
      # on aura un status possible forcément de 6 seulement
      return false if icdocument[4] == '0'
    end
    if icdocument[8] == '1'
      # Si le document commentaires qui existe n'a pas été déposé sur le
      # QDD, le partage ne peut pas être défini.
      return false if icdocument.options[11] == '0'
      # Si le partage n'a pas été défini pour le document commentaires qui
      # existe, on aura un status possible forcément de 6 seulement
      return false if icdocument[12] == '0'
    end
  end
  return true
end #/ documents_sharing_defined?

# Méthode qui doit réparer (ou simuler la réparation) des watchers de
# l'étape lorsqu'ils ont été reconnus incohérents
# Deux cas peuvent se présenter :
#   1) un watcher n'a rien à faire là => il doit être supprimé
#   2) un watcher devrait être trouvé, il est absent => on le crée
def reparer_watchers(simuler = false)
  datawatchers = WATCHER_WTYPE_PER_STATUS[status]
  lines_sql = []
  watchers.each do |wid, wdata|
    next if [datawatchers[:wtype], datawatchers[:maybe]].include?(wdata[:wtype])
    # Sinon, on doit le supprimer
    lines_sql << "DELETE FROM watchers WHERE id = #{wid}"
  end
  # Si le watcher requis par rapport au statut n'existe pas, on le crée
  if not watchers.key?(datawatchers[:wtype])
    lines_sql << "INSERT INTO watchers (wtype, user_id, objet_id, created_at, updated_at) VALUES ('datawatchers[:wtype]', #{user_id}, id, '#{created_at}', '#{created_at}')"
  end

  # On construit la requête SQL
  request = <<-SQL
START TRANSACTION;
#{lines_sql.join(";\n")};
COMMIT;
  SQL
  if simuler
    "Je vais jouer les requêtes : #{lines_sql.join(', ')}."
  else
    db_exec(request)
  end
end #/ reparer_watchers

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
