# encoding: UTF-8
# frozen_string_literal: true
require_relative 'document'
require_relative 'etape'
class IcareCLI
class << self
  # = main =
  # Méthode principale affichant les informations pour l'étape +mid+
  def infos_for_module(mid)
    # L'étape doit exister TODO
    IcModule.exists?(mid) || raise(ERRORS[:unknown_objet])
    objet = IcModule.get(mid)
    clear
    puts "=========================================".bleu
    puts "===                                   ===".bleu
    puts "=== INFORMATIONS SUR ICMODULE ##{mid} ===".bleu
    puts "===                                   ===".bleu
    puts "=========================================".bleu
    # Les données de premier niveau de l'étape
    objet.display_infos
    puts ""
    puts ("="*100).bleu
    puts RC*2
  end #/ infos_for_etape
end # << self
end #/IcareCLI

class IcModule < ContainerClass
include ModuleHelpersObjet
class << self
  def exists?(mid)
    db_count(table, {id: mid}) == 1
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


def display_infos
  display_first_class_data
  display_data_etapes
  display_data_documents
  display_data_watchers
end #/ display_infos

def display_first_class_data
  {
    id:             {name:"ID"},
    f_owner:        {name: "Propriétaire"},
    f_absmodule:    {name:"Module absolue"},
    created_date:   {name:"Création"},
    updated_date:   {name:"Actualisation"},
    started_date:   {name:"Démarrée le"},
    ended_date:     {name:"Finie le"},
    f_options:      {name:"Options"},
    # f_watchers:     {name:"Watchers"},
    # f_documents:    {name:"Documents"},
  }.each do |prop, dprop|
    displine(dprop[:name]||prop.to_s, self.send(prop))
  end
end #/ display_first_class_data

def display_data_etapes
  puts "#{RC}====== ÉTAPES DE TRAVAIL ======".bleu
  @prefix = "     ="
  icetapes.each do |icetape|
    puts "#{RC}====== IcEtape ##{icetape.id}  #{icetape.code_infos}".bleu
    {
      f_absetape:     {name:"Numéro et titre"},
      started_date:   {name:"Démarrée le"},
      ended_date:     {name:"Finie le"},
    }.each do |prop, dprop|
      displine(dprop[:name]||prop.to_s, icetape.send(prop))
    end
  end
end #/ display_data_etapes

def type
  @type ||= "module"
end #/ type

def display_data_documents
  @prefix = "     ="
  puts "#{RC}====== DOCUMENTS DE TRAVAIL ======".bleu
  icdocuments.each do |icdocument|
    puts "#{RC}====== IcDocument ##{icdocument.id} #{icdocument.code_infos}".bleu
    {
      f_name: {name: "Nom d'origine"},
      created_date: {name: "Créé le"},
      icetape_id:   {name: "Pour l’IcEtape"}
    }.each do |prop, dprop|
      displine(dprop[:name]||prop.to_s, icdocument.send(prop))
    end
  end
end #/ display_data_documents

def display_data_watchers

end #/ display_data_watchers


# Les instances des étapes de travail classées par temps
def icetapes
  @icetapes ||= begin
    db_exec("SELECT * FROM icetapes WHERE icmodule_id = ? ORDER BY started_at ASC", id).collect do |de|
      IcEtape.instantiate(de)
    end
  end
end #/ icetapes

def icdocuments
  @icdocuments ||= begin
    request = <<-SQL
SELECT docs.*
FROM icdocuments docs
INNER JOIN icetapes steps ON docs.icetape_id = steps.id
WHERE steps.icmodule_id = ?
ORDER BY
  created_at ASC
    SQL
    db_exec(request, [id]).collect do |dd|
      IcDocument.instantiate(dd)
    end
  end
end #/ icdocuments

def absmodule
  @absmodule ||= begin
    AbsModule.get(absmodule_id) unless absmodule_id.nil?
  end
end #/ absmodule

def f_absmodule
  @f_absmodule ||= begin
    if absmodule_id.nil?
      "- indéfini -".rouge
    else
      "#{absmodule.name} (##{absmodule.id})"
    end
  end
end #/ f_absmodule

def f_etape_id
  @f_etape_id ||= begin
    if icetape_id.nil?
      "- null -"
    else
      "# #{icetape_id}"
    end
  end
end #/ f_etape_id


# Retourne les options formatées
def f_options
  @f_options ||= begin
    "#{options} (inutilisées pour le moment)"
  end
end #/ f_options

end #/IcModule < ContainerClass
