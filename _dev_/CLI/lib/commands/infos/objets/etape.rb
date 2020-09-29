# encoding: UTF-8
# frozen_string_literal: true
require_relative 'module'
require_relative 'document'
class IcareCLI
class << self
  # = main =
  # Méthode principale affichant les informations pour l'étape +oid+
  def infos_for_etape(oid)
    # L'étape doit exister TODO
    IcEtape.exists?(oid) || raise(ERRORS[:unknown_objet])
    objet = IcEtape.get(oid)
    clear
    puts "=========================================".bleu
    puts "===                                   ===".bleu
    puts "=== INFORMATIONS SUR ICETAPE ##{Oid}  ===".bleu
    puts "===                                   ===".bleu
    puts "=========================================".bleu
    # Les données de premier niveau de l'étape TODO
    objet.display_infos
    puts ""
    puts ("="*100).bleu
    puts RC*2
  end #/ infos_for_etape
end # << self
end #/IcareCLI

class IcEtape < ContainerClass
include ModuleHelpersObjet
class << self
  def exists?(id)
    db_count(table, {id: id}) == 1
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

def display_infos
  display_first_class_data
  display_data_module
  display_data_documents
  display_data_watchers
end #/ display_infos

def display_first_class_data
  {
    id:             {name:"ID"},
    f_owner:        {name: "Propriétaire"},
    f_absetape:     {name:"Étape absolue"},
    created_date:   {name:"Création"},
    updated_date:   {name:"Actualisation"},
    started_date:   {name:"Démarrée le"},
    expected_date:  {name:"Fin attendue le"},
    expected_coms:  {name:"Coms attendus le"},
    ended_date:     {name:"Finie le"},
    f_status:       {name:"Statut"},
    f_own_work:     {name:"Travail propre"},
    f_options:      {name:"Options"},
    # f_watchers:     {name:"Watchers"},
    # f_documents:    {name:"Documents"},
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

def display_data_documents
  puts "#{prefix} DOCUMENTS #{prefix}".bleu

end #/ display_data_documents

def display_data_watchers

end #/ display_data_watchers

def icmodule
  @icmodule ||= begin
    if not(icmodule_id.nil?) && IcModule.exists?(icmodule_id)
      IcModule.get(icmodule_id)
    end
  end
end #/ icmodule


def absetape
  @absetape ||= begin
    AbsEtape.get(absetape_id) unless absetape_id.nil?
  end
end #/ absetape
def f_absetape
  @f_absetape ||= begin
    if not absetape.nil?
      "#{absetape.numero}. #{absetape.titre} (##{absetape_id})"
    else
      "- indéfinie -".rouge
    end
  end
end #/ f_absetape

def expected_date
  @expected_date ||= begin
    if expected_end.nil?
      "- non définie -".rouge
    else
      "#{formate_date(expected_end)} (#{expected_end})"
    end
  end
end #/ expected_date
def expected_coms
  @expected_coms ||= begin
    if expected_comments.nil?
      "- non définie -".mauve
    else
      formate_date(expected_comments)
    end
  end
end #/ expected_coms

def f_status
  @f_status ||= begin
    if status.nil?
      "- indéfini -".rouge
    elsif status == 0
      "- mauvaise valeur (0) -".rouge
    else
      "#{DATA_STATUS[status][:name]} (#{status})"
    end
  end
end #/ f_status


def f_own_work
  @f_own_work ||= begin
    if travail_propre
      "Oui. Commence par #{travail_propre[0..50]}"
    else
      "Non"
    end
  end
end #/ f_own_work

def f_options
  @f_options ||= options.to_s.ljust(8,'0') # pour le moment
end #/ f_options


def type # pour le code
  @type ||= "etape"
end #/ type


DATA_STATUS = {
  1 => {name: "En cours de travail"},
  2 => {name: "Travail transmis mais pas downloadé par moi"},
  3 => {name: "En cours de commentaire"},
  4 => {name: "Commentaires envoyés"},
  5 => {name: "Commentaires chargés par l'icarien (attente de dépôt QDD)"},
  6 => {name: "Documents déposés sur le QDD (attente de partage)"},
  7 => {name: "Partage documents défini"},
  8 => {name: "Cycle complet terminé"}
}
end #/IcEtape < ContainerClass
