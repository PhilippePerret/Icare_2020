# encoding: UTF-8
# frozen_string_literal: true
class CheckedDocument < ContainerClass
extend CheckClassMethods
include HelpersWritingMethods
class << self

  # # = main =
  # #
  # # Check des icdocument ou de l'icdocument +did+
  # #
  # def check(did = nil)
  #   (did.nil? ? alldocuments.values : [get(did)]).each do |m|
  #     m.check || return # pour s'arrêter
  #   end
  #   return true # pour poursuivre
  # end #/ check

  def alldocuments
    @alldocuments ||= begin
      h = {}
      db_exec("SELECT * FROM icdocuments ORDER BY created_at ASC").each do |dd|
        doc = CheckedDocument.instantiate(dd)
        h.merge!(doc.id => doc)
      end; h
    end
  end #/ alldocuments
  alias :all_instances :alldocuments

  def existe_sur_le_qdd?(name)
    all_documents_on_qdd.key?(name)
  end #/ existe_sur_le_qdd?

  # Retourne tous les documents existants sur le QDD (pour ne pas à
  # envoyer une requête chaque fois)
  def all_documents_on_qdd
    @all_documents_on_qdd ||= begin
      request = <<-SSH
ssh #{SSH_SERVER} ruby << CODE
require 'json'
puts Dir["www/_lib/data/qdd/**/*.pdf"].collect{|p|File.basename(p)}.to_json
CODE
      SSH
      res = `#{request}`
      h = {}
      JSON.parse(res).each do |fname|
        h.merge!(fname => true)
      end
      h # return
    end
  end #/ all_documents_on_qdd

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

def qdd_path(dtype)
  "_lib/data/qdd/#{qdd_filename(dtype)}"
end #/ qdd_path

QDD_FILE_NAME = '%{module}_etape_%{etape}_%{pseudo}_%{doc_id}_%{dtype}.pdf'
def qdd_filename(dtype)
  @template ||= begin
    QDD_FILE_NAME % {
      module: icetape.icmodule.absmodule.module_id.camelize,
      etape:  icetape.absetape.numero,
      pseudo: has_owner && owner.pseudo.dup.titleize,
      doc_id: id,
      dtype: '%s'
    }
  end
  @template % dtype.to_s
end #/ qdd_filename

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

# Retourne TRUE si le document est marqué déposé sur le QDD
def has_status_on_qdd
  (@it_has_status_on_qdd ||= begin
    (
      (original_exists? || comments_exists?) &&
      (original_exists? == original_deposed?) &&
      (comments_exists? == comments_deposed?)
    ) ? :true : :false
  end) == :true
end #/ has_status_on_qdd

def original_exists?
  options[0] == '1'
end #/ original_exists?
def original_deposed?
  options[3] == '1'
end #/ original_deposed?
def comments_exists?
  options[8] == '1'
end #/ comments_exists?
def comments_deposed?
  options[11] == '1'
end #/ comments_deposed?

# ---------------------------------------------------------------------
#
#   Méthode de check
#
# ---------------------------------------------------------------------

def document_exists_on_qdd
  if original_exists?
    # res = `ssh #{SSH_SERVER} test -f "www/#{qdd_path(:original)}" && echo "YES" || echo "NO"`
    CheckedDocument.existe_sur_le_qdd?(qdd_filename(:original)) || return
  end
  if comments_exists?
    # res = `ssh #{SSH_SERVER} test -f "www/#{qdd_path(:comments)}" && echo "YES" || echo "NO"`
    CheckedDocument.existe_sur_le_qdd?(qdd_filename(:comments)) || return
  end
  return true
end #/ document_exists_on_qdd


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
