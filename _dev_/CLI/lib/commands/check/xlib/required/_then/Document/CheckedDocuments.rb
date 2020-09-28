# encoding: UTF-8
# frozen_string_literal: true
class CheckedDocument < ContainerClass
  include HelpersWritingMethods
class << self

  # = main =
  #
  # Check des icdocument ou de l'icdocument +did+
  #
  def check(did = nil)
    (did.nil? ? alldocuments.values : [get(did)]).each { |m| m.check }
  end #/ check

  def alldocuments
    @alldocuments ||= begin
      h = {}
      db_exec("SELECT * FROM icdocuments ORDER BY created_at ASC").each do |dd|
        doc = CheckedDocument.instantiate(dd)
        h.merge!(doc.id => doc)
      end; h
    end
  end #/ alldocuments

  def table
    @table ||= 'icdocuments'
  end #/ table

end # /<< self


# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def ref
  @ref ||= "document ##{id} (d'icarien ##{user_id})"
end #/ ref

# ---------------------------------------------------------------------
#
#   Méthodes de données
#
# ---------------------------------------------------------------------

def la_chose
  @la_chose ||= "le document"
end #/ la_chose

def icetape
  @icetape ||= begin
    if CheckedEtape.exists?(icetape_id)
      CheckedEtape.get(icetape_id)
    end
  end
end #/ icetape

# ---------------------------------------------------------------------
#
#   Méthodes de condition
#
# ---------------------------------------------------------------------

def has_icetape_id
  icetape_id != nil
end #/ has_icetape_id

def has_icetape
  icetape_id && CheckedEtape.exists?(icetape_id)
end #/ has_icetape


# ---------------------------------------------------------------------
#
#   Méthode de changement des données
#
# ---------------------------------------------------------------------


def original_name_composed
  @original_name_composed ||= "Document-#{id}-de-#{user_id}-pour-#{icetape_id}.doc"
end #/ original_name_compose


# {CheckedUser} Méthode qui recherche un propriétaire possible pour le document
# Cette méthode est utile quand :
#   - le propriétaire défini n'existe pas
#   - user_id n'est pas défini dans le document ni dans l'étape
#   - user_id n'est pas défini, pas plus que icetape_id
#
def owner_possible
  @owner_possible ||= begin
    search_owner_possible if not(@owner_possible_already_searched)
  end
end
def search_owner_possible
  @owner_possible_already_searched = true
  # Si l'identifiant de l'étape est défini est qu'elle a un propriétaire,
  # on prend ce propriétaire
  if not(icetape_id.nil?) && CheckedUser.exists?(icetape.user_id)
    return CheckedUser.get(icetape.user_id)
  end

  # Si l'icetape du document n'est pas définie
  if icetape_id.nil? || not(CheckedEtape.exists?(icetape_id))
    puts "L'icetape_id est nil TODO : rechercher un étape qui correspondrait".rouge

  else
    # L'étape existe mais n'a pas de propriétaire à prendre
    modules_candidats = CheckedModule.find({created_before: created_at, ended_after: created_at })
    # S'il y a un seul candidat, c'est forcément lui
    if modules_candidats.count == 1
      return CheckedUser.get(modules_candidats.keys.first)
    end

    if CheckCase.reparer?
      if CheckCase.simuler?

      else
        puts "#{RC*2}DOCUMENT (pour attribution de propriétaire)"
        puts "#{TABU}“#{original_name}” du #{formate_date(created_at)}"
        puts "MODULES CANDIDATS"
        candidats = modules_candidats.collect do |idmod, mod|
          name = "#{TABU}Module ##{idmod} “#{mod.absmodule.name}” de icarien ##{mod.user_id} du #{formate_date(mod.created_at)} au #{mod.ended_at ? formate_date(mod.ended_at) : '-en cours-'}"
          {name: name, value: idmod}
        end
        candidats << {name: "#{TABU}Renoncer", value: :cancel}
        choix = Q.select("#{TABU}Quel module choisir ?") do |q|
          q.choices candidats
          q.per_page candidats.count
        end
        puts "\r#{' '*90}" # pour effacer la ligne
        if choix == :cancel
          return nil
        end
        candidat_user = CheckedUser.get(modules_candidats[choix.to_i].user_id)
        # On en profite pour corriger aussi le propriétaire de l'étape du
        # document
        if icetape_id
          icetape.set(user_id: candidat_user.id)
        end
        return candidat_user
      end
    end

  end

  return nil
end #/ owner_possible

end #/CheckedDocument
