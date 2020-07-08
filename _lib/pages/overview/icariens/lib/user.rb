# encoding: UTF-8
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
  BOUTON_EDIT   = '<span class="tool"><a href="admin/icarien?uid=%i" class="small btn discret">'+UI_TEXTS[:btn_edit]+'</a></span>'.freeze

  # = main =
  #
  # Méthode d'affichage principal de l'icarien dans la salle des icariens.
  # Prépare sa "carte" en fonction de son statut.
  #
  CARD_ACTIF = <<-HTML.strip.freeze
<div id="icarien-%{id}" class="icarien">
  <span class="pseudo big">%{picto} %{pseudo}</span> est à l’atelier depuis le
  <span class="date-signup">%{date_signup}</span> (<span class="duree">%{duree}</span>).
  <span>%{Il} suit <span class='module'>%{module_courant}</span>.</span>
  <span class="small">
    %{span_pause}
    %{precedemment}
    %{div_tools}
  </span>
</div>
  HTML

  SPAN_PRECEDEMMENT = <<-HTML.strip.freeze
<span> Précédemment, %{pseudo} a suivi %{modules_suivis}.</span>
  HTML

  CARD_INACTIF = <<-HTML.strip.freeze
<div id="icarien-%{id}" class="icarien">
  <span class="pseudo big">%{picto} %{pseudo}</span> a travaillé à l’atelier du
  <span class="date-signup">%{date_signup}</span> au <span class="date signout">%{date_signout}</span>
  <span class="duree">(%{duree})</span>.
  <span class="small">%{pseudo} a suivi %{modules_suivis}.</span>
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
      divcontact << BOUTON_EDIT % id
    end
    div_tools = Tag.div(text:divcontact.join, class:'tools')

    datacard = {
      picto: visage, id:id, pseudo: pseudo,
      date_signup: formate_date(created_at, {jour:true}).downcase,
      date_signout: formate_date(date_sortie, {jour:true}).downcase,
      duree: formate_duree(created_at, date_sortie, {nojours: true}),
      s: plusieurs_modules? ? 's' : '',
      e: fem(:e),
      Il:fem(:Elle),
      modules_suivis: modules_suivis,
      span_pause: span_pause,
      div_tools: div_tools
    }
    case true
    when actif?
      datacard.merge!(precedemment: precedemment(datacard), module_courant: icmodule.name_with_project)
      CARD_ACTIF % datacard
    when inactif?   then CARD_INACTIF % datacard
    when recu_inactif?  then CARD_RECU_INACTIF % datacard
    when candidat?  then CARD_CANDIDAT % datacard
    when en_pause?  then CARD_ACTIF % datacard
    else '' # au cas où
      # raise "Impossible de traiter #{pseudo} qui n'est ni actif, ni inactif, ni candidat (en pause ?) (#{data.inspect})"
    end
  end #/ out

  def precedemment(datacard)
    return '' unless actif?
    return '' if modules.count == 1
    SPAN_PRECEDEMMENT % datacard.merge(modules_suivis: modules_suivis)
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

  def modules_suivis
    if actif?
      # <= C'est un icarien en activité
      # => Il ne faut mettre que les modules hors du module courant
      modules.collect { |m| m.id == icmodule_id ? nil : m.name_with_project }
    else
      # <= C'est un ancien
      # => On prend tous ses modules
      modules.collect { |m| m.name_with_project rescue nil}
    end.compact.pretty_join
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

# Retourne la date de dernière activité de l'icarien actif (pour savoir
# s'il est vraiment actif)
def date_last_activite
  @date_last_activite ||= begin
    # Date de dernier document
    request = "SELECT updated_at FROM icdocuments WHERE user_id = #{id} ORDER BY updated_at DESC LIMIT 1".freeze
    last_document = db_exec(request).first
    last_document.nil? ? Time.now.to_i : last_document[:updated_at]
  end
end #/ date_last_activite

# ---------------------------------------------------------------------
#
#   MÉTHODES DE CLASSE
#
# ---------------------------------------------------------------------

class << self
  # Préparation des listes des icariens en fonction de leur statut
  def dispatch_all_users
    @listes = {
      actif:    [],
      candidat: [],
      inactif:  [],
      recu:     [],
      pause:    [],
      destroyed:[],
      undefined:[],
      guest:[]
    }
    all_but_users_out.each do |u|
      state = u.statut
      if u.actif?
        # Quand c'est un actif, on regarde quand était sa dernière activité
        # pour voir si c'est vraiment un actif. Si elle remonte à plus de
        # 6 mois, il passe en inactif (pour la liste seulement).
        if u.date_last_activite < (Time.now.to_i - (6 * 31).days)
          log("--- #{u.pseudo} rétrogradé d'actif à inactif (dernière activité : #{formate_date(u.date_last_activite)})")
          state = :inactif
        end
      end
      @listes[state] << u
    end
  end #/ dispatch_all_users

  def actifs
    @listes[:actif]
  end #/ actifs
  def en_pause
    @listes[:pause]
  end #/ en_pause
  def anciens
    @listes[:inactif]
  end #/ anciens
  def candidats
    @listes[:candidat]
  end #/ candidats
  def recus
    @listes[:recu]
  end #/ recus
  def all_but_users_out
    @all_but_users_out ||= find("SUBSTRING(options,1,1) = 0 AND id != 9 AND SUBSTRING(options,4,1) = '0'".freeze).values
  end #/ all_but_users_out
end #/<< self
end #/User
