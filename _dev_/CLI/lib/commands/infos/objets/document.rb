# encoding: UTF-8
# frozen_string_literal: true
require_relative 'module'
require_relative 'document'
class IcareCLI
class << self
  # = main =
  # Méthode principale affichant les informations pour l'étape +did+
  def infos_for_document(did)
    # L'étape doit exister TODO
    IcDocument.exists?(did) || raise(ERRORS[:unknown_objet])
    objet = IcDocument.get(did)
    clear
    puts "==========================================".bleu
    puts "===                                    ===".bleu
    puts "=== INFORMATIONS SUR ICDOCUMENT ##{did.to_s.ljust(5)} ===".bleu
    puts "===                                    ===".bleu
    puts "==========================================".bleu
    # Les données de premier niveau de l'étape TODO
    objet.display_infos
    puts ""
    puts ("="*100).bleu
    puts RC*2
  end #/ infos_for_document
end # << self
end #/IcareCLI



class IcDocument < ContainerClass
include ModuleHelpersObjet
class << self
  def exists?(mid)
    db_count(table, {id: mid}) == 1
  end #/ exists?
  def table
    @table ||= 'icdocuments'
  end #/ table
end # /<< self


# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

def display_infos
  display_first_class_data
  display_data_module
  display_data_etape
end #/ display_infos

def display_first_class_data
  {
    id:             {name:"ID"},
    f_owner:        {name: "Propriétaire"},
    f_icetape:      {name:"Étape icarien"},
    f_absetape:     {name:"Étape absolue"},
    created_date:   {name:"Création"},
    updated_date:   {name:"Actualisation"},
    f_options:      {name:"Options"},
  }.each do |prop, dprop|
    displine(dprop[:name]||prop.to_s, self.send(prop))
  end
end #/ display_first_class_data

def display_data_module
  @prefix = "     ="
  puts "====== ICMODULE ======".bleu
  {
    f_id: {name: "ID"},
    f_etape_id: {name: "ID étape courante"},
    started_date:   {name:"Amorcé le"},
    ended_date:     {name:"Achevé le"},
  }.each do |prop, dprop|
    displine(dprop[:name]||prop.to_s, icmodule.send(prop))
  end
end #/ display_data_module

def display_data_etape

end #/ display_data_etape

def type # pour le code
  @type ||= "document"
end #/ type

# ---------------------------------------------------------------------
#
#   Méthodes d'helper
#
# ---------------------------------------------------------------------

def f_name
  @f_name ||= original_name
end #/ f_name

def f_icetape
  @f_icetape ||= begin
    if icetape_id.nil?
      "- indéfini -".rouge
    else
      "##{icetape_id} #{icetape.code_infos}"
    end
  end
end #/ f_icetape

def f_absetape
  @f_absetape ||= begin
    if icetape.nil?
      "- indéfinie -".rouge
    else
      icetape.f_absetape
    end
  end
end #/ f_absetape

# ---------------------------------------------------------------------
#
#   Méthodes de données
#
# ---------------------------------------------------------------------

def icetape
  @icetape ||= begin
    IcEtape.get(icetape_id) unless icetape_id.nil?
  end
end #/ icetape

def icmodule
  @icmodule ||= begin
    icetape.icmodule unless icetape.nil?
  end
end #/ icmodule
end #/IcDocument < ContainerClass
