# encoding: UTF-8
# frozen_string_literal: true
require_relative 'module'
require_relative 'document'
class IcareCLI
class << self
  # = main =
  # Méthode principale affichant les informations pour l'étape +uid+
  def infos_for_icarien(uid)
    # L'étape doit exister TODO
    User.exists?(uid) || raise(ERRORS[:unknown_objet])
    objet = User.get(uid)
    clear
    inter = " INFORMATIONS SUR ICARIEN#{objet.femme? ? 'NE' : ''} ##{uid.to_s.ljust(5)} "
    lenin = inter.length
    puts ("="*(lenin+6)).bleu
    puts "===#{' '*lenin}===".bleu
    puts "===#{inter}===".bleu
    puts "===#{' '*lenin}===".bleu
    puts ("="*(lenin+6)).bleu
    # Les données de premier niveau de l'étape TODO
    objet.display_infos
    puts ""
    puts ("="*100).bleu
    puts RC*2
  end #/ infos_for_icarien
end # << self
end #/IcareCLI


class User < ContainerClass
include ModuleHelpersObjet
class << self
  def exists?(uid)
    db_count(table, {id: uid})
  end #/ exists?
  def table
    @table ||= 'users'
  end #/ table
end # /<< self


# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------


def display_infos
  display_first_class_data
  display_data_modules
  display_data_etapes
  display_data_documents
  display_data_watchers
end #/ display_infos

def display_first_class_data
  {
    id:               {name:"ID"},
    pseudo:           {name:"Pseudo"},
    created_date:     {name:"Inscription"},
    updated_date:     {name:"Actualisation"},
    mail:             {name:"Mail"},
    f_options:        {name:"Options"},
    f_statut:         {name:"Statut d'après options"},
    f_mail_conf:      {name:"Confirmation du mail"},
    f_redirection:    {name:"Après l'identification"},
    f_contact_admin:  {name:"Contact administration"},
    f_contact_icare:  {name:"Contact icariens"},
    f_contact_monde:  {name:"Contact avec le monde"},
  }.each do |prop, dprop|
    displine(dprop[:name]||prop.to_s, self.send(prop))
  end
end #/ display_first_class_data


def display_data_modules
  @prefix = "     ="
  puts "#{RC}====== DATA MODULES ======".bleu
  icmodules.each do |icmodule|
    puts "#{RC}   === IcModule ##{icmodule.id} #{icmodule.code_infos} ===".bleu
    {
      f_absmodule:    {name:"Données absolues"},
      f_etape_id:     {name: "ID étape courante"},
      started_date:   {name:"Amorcé le"},
      ended_date:     {name:"Achevé le"},
    }.each do |prop, dprop|
      displine(dprop[:name]||prop.to_s, icmodule.send(prop))
    end
  end
end #/ display_data_modules

def display_data_etapes

end #/ display_data_etapes

def display_data_documents

end #/ display_data_documents

def display_data_watchers

end #/ display_data_watchers
# ---------------------------------------------------------------------
#
#   Méthodes de données
#
# ---------------------------------------------------------------------

def type
  @type ||= "icarien"
end #/ type

def femme?
  (@is_femme ||= (sexe == 'F') ? :true : :false) == :true
end #/ femme?

# Retourne les instances IcModule en liste Array
def icmodules
  @icmodules ||= begin
    db_exec("SELECT * FROM icmodules WHERE user_id = ?", [id]).collect do |dm|
      IcModule.instantiate(dm)
    end
  end
end #/ icmodules

# ---------------------------------------------------------------------
#
#   Méthode d'helper (formatage)
#
# ---------------------------------------------------------------------

def e
  @e ||= (femme? ? 'e' : '')
end #/ e
def ne
  @ne ||= (femme? ? 'ne' : '')
end #/ ne
def ve
  @ve ||= (femme? ? 've' : 'f')
end #/ ve

STATUS_FROM_OPTIONS = {
  '1' => "- impossible -".rouge, '2' => "Acti%{ve}", '3' => "Candidat%{e}", '4' => "Inacti%{ve} (ancien%{ne})", '5' => "Détruit%{e}", '6' => "Simple reçu%{e}", '7' => "- impossible -".rouge, '8' => "En pause"
}
def f_statut
  @f_statut ||= begin
    # if options[3] == '1'
    #   "détruit#{e}"
    # else
      STATUS_FROM_OPTIONS[options[16]] % {e: e, ve: ve, ne: ne}
    # end
  end
end #/ f_statut


def f_mail_conf
  @f_mail_conf ||= options[2] == '1' ? 'oui' : 'non'.rouge
end #/ f_mail_conf

def f_freq_mails
  @f_freq_mails ||= begin
    case options[4]
    when '0' then "quotidient"
    when '1' then "hebdomadaire"
    when '9' then "aucun mail"
    end
  end
end #/ f_freq_mails

def f_redirection
  @f_redirection ||= begin
    require './_lib/_pages_/user/login/constants'
    "rejoint le "+REDIRECTIONS_AFTER_LOGIN[options[18].to_i][:hname].downcase
  end
end #/ f_redirection

def f_contact_admin
  @f_contact_admin ||= contact_for(options[26])
end #/ f_contact_admin
def f_contact_icare
  @f_contact_icare ||= contact_for(options[27])
end #/ f_contact_icare
def f_contact_monde
  @f_contact_monde ||= contact_for(options[28])
end #/ f_contact_monde

def contact_for(bit)
  bit = bit.to_i
  case bit
  when 0 then "aucun"
  else
    par = []
    par << "mail"   if bit & 1 > 0
    par << "frigo"  if bit && 2 > 0
    par.join(' et ')
  end
end #/ contact_for
end #/User < ContainerClass
