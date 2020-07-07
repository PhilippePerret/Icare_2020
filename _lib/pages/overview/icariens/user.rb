# encoding: UTF-8
require_modules(['user/modules'])
require_relative 'constants'


=begin
  TODO POURSUIVRE LE DÉVELOPPEMENT
    - ajouter le titre du projet quand il est défini pour un module
    - ajouter les modules (pour les inactifs)
    - ajouter les autres modules pour les actifs (s'il y en a)
    - modifier le message "à l'atelier depuis" pour les inactifs (mettre
      un truc comme "inscrit/e le…")
=end

class User

  BOUTON_FRIGO  = '<span class="tool"><a href="contact/frigo?op=contact&touid=%i" class="small btn discret">'+UI_TEXTS[:btn_message_frigo]+'</a></span>'.freeze
  BOUTON_MAIL   = '<span class="tool"><a href="contact?ui=%i" class="small btn discret">'+UI_TEXTS[:btn_lui_ecrire]+'</a></span>'.freeze
  BOUTON_HISTO  = '<span class="tool"><a href="bureau/historique?uid=%i" class="small btn discret">'+UI_TEXTS[:btn_voir_historique]+'</a></span>'.freeze

# Requête simple pour obtenir les noms des modules suivis par l'icarien
REQUEST_MODULES_SUIVIS = <<-SQL.strip.freeze
  SELECT icm.id, abs.name
  FROM icmodules AS icm
  INNER JOIN absmodules AS abs ON icm.absmodule_id = abs.id
  WHERE icm.user_id = %{id}
SQL

REQUEST_AUTRES_MODULES_SUIVIS = <<-SQL.strip.freeze
  SELECT icm.id, abs.name
  FROM icmodules AS icm
  INNER JOIN absmodules AS abs ON icm.absmodule_id = abs.id
  WHERE icm.user_id = %{id} AND icm.id != %{current}
SQL

  # = main =
  #
  # Méthode d'affichage principal de l'icarien dans la salle des icariens.
  # Prépare sa "carte". Elle doit ressembler à ça :
  # ACTIF
  #    MAchin est à l'atelier depuis le <date>. Il/Elle travaille sur
  #    le module xxx (nom projet). Il/Elle a précédemment suivi les
  #     modules xxx, xxx (nom projet) et xxx.
  # INACTIF
  #   Machin s'est inscrit/e le <date>. Il/Elle a suivi les modules
  #   xxx (nom projet), xxx exxx.
  # CANDIDAT
  #   Machin a posé sa candidature pour l'atetelier Icare le <date>.
  #
  CARD_ACTIF = <<-HTML.strip.freeze
<div id="icarien-%{id}" class="icarien">
  <span class="pseudo big">%{picto} %{pseudo}</span> est à l’atelier depuis le <span class="date-signup">%{date_signup}</span>.
  <span>%{Il} suit le module <span class='module'>%{module_courant}</span>.</span>
  %{span_pause}
  %{precedemment}
  %{div_tools}
</div>
  HTML

  SPAN_PRECEDEMMENT = <<-HTML.strip.freeze
<span> Précédemment, %{modules_suivis}.</span>
  HTML

  CARD_INACTIF = <<-HTML.strip.freeze
<div id="icarien-%{id}" class="icarien">
  <span class="pseudo big">%{picto} %{pseudo}</span> a travaillé à l’atelier du
  <span class="date-signup">%{date_signup}</span> au <span class="date signout">%{date_signout}</span>.
  %{modules_suivis}
  %{div_tools}
</div>
  HTML

  CARD_CANDIDAT = <<-HTML.strip.freeze
<div id="icarien-%{id}" class="icarien">
  <span class="pseudo big">%{picto} %{pseudo}</span> vient de déposer sa candidature. %{Elle} est en attente de réponse.
</div>
  HTML

  CARD_RECU_INACTIF = <<-HTML.strip.freeze
<div id="icarien-%{id}" class="icarien">
  <span class="pseudo big">%{picto} %{pseudo}</span> vient d’être reçu%{e} à l’atelier.
  %{modules_suivis}
  %{div_tools}
</div>
  HTML
  SPAN_MODULES_SUIVIS = <<-HTML.strip.freeze
%{pseudo} a suivi le%{s} module%{s} %{modules}
  HTML

  SPAN_PAUSE = '<span class="pause"> Actuellement %{pseudo} est en pause.</span>'.freeze

  def out

    divcontact = []
    divcontact << BOUTON_HISTO % id if histo_enabled?
    divcontact << BOUTON_FRIGO % id if frigo_enabled?
    divcontact << BOUTON_MAIL  % id if mail_enabled?
    if user.admin?
      # Boutons administration ?
    end
    div_tools = Tag.div(text:divcontact.join, class:'tools')

    datacard = {
      picto: visage, id:id, pseudo: pseudo,
      date_signup: formate_date(created_at, {jour:true}).downcase,
      date_signout: formate_date(date_sortie, {jour:true}).downcase,
      s: plusieurs_modules? ? 's' : '',
      e: fem(:e),
      Il:fem(:Elle),
      modules_suivis: modules_suivis,
      module_courant: module_courant,
      precedemment: precedemment,
      span_pause: span_pause,
      div_tools: div_tools
    }
    case true
    when actif?     then CARD_ACTIF % datacard
    when inactif?   then CARD_INACTIF % datacard
    when recu_inactif?  then CARD_RECU_INACTIF % datacard
    when candidat?  then CARD_CANDIDAT % datacard
    when en_pause?  then CARD_ACTIF % datacard
    else '' # au cas où
      # raise "Impossible de traiter #{pseudo} qui n'est ni actif, ni inactif, ni candidat (en pause ?) (#{data.inspect})"
    end
  end #/ out

  def precedemment
    return '' unless actif?
    return '' if modules.count == 1
    SPAN_PRECEDEMMENT % {modules_suivis: modules_suivis}
  end #/ precedemment

  def plusieurs_modules?
    if actif?
      modules.count > 3 # le courant plus deux autres
    elsif inactif?
      modules.count > 1 # Au moins deux
    else
      false
    end
  end #/ plusieurs_modules?

  # Module courant de l'actif
  def module_courant
    '[MODULE COURANT]'
  end #/ module_courant

  def modules_suivis
    '[LES MODULES SUIVIS]'
  end #/ modules_suivis

  def span_pause
    return '' unless en_pause?
    SPAN_PAUSE % {pseudo: pseudo}
  end #/ span_pause


  # Retourne TRUE si le contact est possible avec l'icarien
  def frigo_enabled?
    return false if user.id == id
    return true if user.admin? && (type_contact_admin & 2 > 0)
    return true if user.icarien? && (type_contact_icariens & 2 > 0)
    return (type_contact_world & 2) > 0
  end #/ frigo_enabled?

  def mail_enabled?
    return false if user.id == id
    return true if user.admin? && (type_contact_admin & 1 > 0)
    return true if user.icarien? && (type_contact_icariens & 1 > 0)
    return (type_contact_world & 1) > 0
  end #/ mail_enabled?

  def histo_enabled?
    return true if user.admin? || id == user.id
    return true if user.icarien? && histo_shared_with_icariens?
    return histo_shared_with_world?
  end #/ histo_enabled?

  def histo_shared_with_icariens?
    option(21) & 1 > 0
  end #/ histo_shared_with_icariens
  def histo_shared_with_world?
    option(21) & 8 > 0
  end #/ histo_shared_with_world?

# ---------------------------------------------------------------------
#
#   MÉTHODES DE CLASSE
#
# ---------------------------------------------------------------------

class << self
  # TODO : on va plutôt dispatcher en une seule fois plutôt que de
  # passer à chaque fois en revue
  def dispatch_all_users
    @listes = {
      actif:    [],
      candidat: [],
      inactif:  [],
      recu:     [],
      pause:    []
    }
    all_but_users_out.each do |u|
      
    end
  end #/ dispatch_all_users

  def actifs
    all_but_users_out.select { |u| u.actif? }
  end #/ actifs
  def en_pause
    all_but_users_out.select { |u| u.statut == :pause }
  end #/ en_pause
  def anciens
    all_but_users_out.select { |u| u.statut == :inactif }
  end #/ anciens
  def candidats
    all_but_users_out.select { |u| u.statut == :candidat }
  end #/ candidats
  def recus
    all_but_users_out.select { |u| u.statut == :recu }
  end #/ recus
  def all_but_users_out
    @all_but_users_out ||= find("SUBSTRING(options,1,1) = 0 AND id != 9 AND SUBSTRING(options,4,1) = '0'".freeze).values
  end #/ all_but_users_out
end #/<< self
end #/User
