# encoding: UTF-8
# frozen_string_literal: true
require_relative 'constants'

class User

# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self


end
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# = main =
#
# Sortie pour l'affichage de l'icarien en question
def out

  divcontact = []
  divcontact << BOUTON_VISIT_AS % [id, fem(:elle)] if user.admin?
  divcontact << BOUTON_HISTO % id if histo_enabled?
  divcontact << BOUTON_FRIGO % id if frigo_enabled?
  divcontact << BOUTON_MAIL  % id if mail_enabled?
  # Si c'est l'administrateur qui visite la salle des icariens, un bouton
  # lui permet d'éditer l'icarien.
  if user.admin?
    divcontact << BOUTON_EDIT % id
  end
  div_tools = Tag.div(text:divcontact.join, class:'tools')

  datacard = {
    picto: visage,
    id:id,
    pseudo: pseudo,
    date_signup: formate_date(created_at, {jour:false}).downcase,
    date_signout: formate_date(date_sortie, {jour:false}).downcase,
    duree: formate_duree(created_at, date_sortie, {nojours: true}),
    s: plusieurs_modules? ? 's' : '',
    e: fem(:e),
    Elle:fem(:Elle),
    Il:fem(:Elle),
    modules_suivis: formated_modules_suivis,
    span_pause: span_pause,
    div_tools: div_tools
  }
  carte = case true
  when vrai_actif?
    datacard.merge!(precedemment: precedemment(datacard), module_courant: icmodule.name_with_project, class_statut: 'actif')
    CARD_ACTIF
  when faux_actif?
    # datacard.merge!(precedemment: precedemment(datacard), module_courant: icmodule.name_with_project, class_statut: 'en-pause')
    datacard.merge!(precedemment: precedemment(datacard), module_courant: icmodule.name_with_project, class_statut: 'en-pause')
    CARD_ACTIF
  when inactif?       then CARD_INACTIF
  when recu_inactif?  then CARD_RECU_INACTIF
  when candidat?      then CARD_CANDIDAT
  when en_pause?
    datacard.merge!(class_statut: 'en-pause')
    CARD_ACTIF
  else
    return ''# raise "Impossible de traiter #{pseudo} qui n'est ni actif, ni inactif, ni candidat (en pause ?) (#{data.inspect})"
  end
  carte % datacard
end #/ out

# ---------------------------------------------------------------------
#   HELPERS MÉTHODES
# ---------------------------------------------------------------------

# OUT   {String} Le texte à ajouter à la carte pour les modules suivis
#       avant le module courant.
#
# IN    {Hash} Les données pour la carte (template)
#
def precedemment(datacard)
  return '' if not actif?
  return '' if modules.count == 1
  return '' if autres_modules_suivis.count == 0
  SPAN_PRECEDEMMENT % datacard.merge(modules_suivis: formated_modules_suivis)
end #/ precedemment

# Helper pour formater la liste des autres modules suivis
def formated_modules_suivis
  autres_modules_suivis.pretty_join
end #/ formated_modules_suivis

# Le span avec les pauses.
def span_pause
  return '' unless en_pause?
  SPAN_PAUSE % {pseudo: pseudo}
end #/ span_pause

# ---------------------------------------------------------------------
#   MÉTHODES DE DONNÉES
# ---------------------------------------------------------------------

# Méthode qui retourne les modules suivis par l'icarien, hors le module
# suivi actuellement s'il est actif.
# En fait, cela revient à retourner les modules FINIS.
#
# OUT   {Array}
def autres_modules_suivis
  @autres_modules_suivis ||= begin
    modules.collect do |m|
      if actif? && m.id == icmodule_id
        nil # c'est le module courant d'un icarien actif
      elsif m.ended_at.nil?
        # <= La date de fin n'est pas définie
        # => C'est un module inachevé, on ne le compte pas
        nil
      elsif ((m.ended_at.to_i - m.started_at.to_i) / 1.day) < 20
        # <= Le module a une durée de vie de moins de 20 jours
        # => Il n'a pas vraiment été suivi, on ne le compte pas
        nil
      else
        # <= Le module est conforme et terminé
        # => On le prend comme "autre module"
        m.name_with_project
      end
    end.compact
  end
end #/ autres_modules_suivis

# ---------------------------------------------------------------------
#   MÉTHODES D'ÉTAT
# ---------------------------------------------------------------------

def plusieurs_modules?
  autres_modules_suivis.count > 1 # Au moins deux
end #/ plusieurs_modules?

# Méthodes qui déterminent les boutons qui vont apparaitre pour
# l'icarien en fonction de ses préférences.
# ---------------------------------------------------------------------

# Retourne TRUE si le contact est possible avec l'icarien
def frigo_enabled?
  return false if user.id == id
  return true if user.admin? && (type_contact_admin & 2 > 0)
  return true if user.icarien? && (type_contact_icariens & 2 > 0)
  return (type_contact_world & 2) > 0
end

def mail_enabled?
  return false if user.id == id
  return true if user.admin? && (type_contact_admin & 1 > 0)
  return true if user.icarien? && (type_contact_icariens & 1 > 0)
  return (type_contact_world & 1) > 0
end

def histo_enabled?
  return true if user.admin? || id == user.id
  return true if user.icarien? && histo_shared_with_icariens?
  return histo_shared_with_world?
end

def histo_shared_with_icariens?
  option(21) & 1 > 0
end #/ histo_shared_with_icariens
def histo_shared_with_world?
  option(21) & 8 > 0
end #/ histo_shared_with_world?

def vrai_actif?
  actif? && date_last_activite > (Time.now - 6*4.weeks)
end #/ vrai_actif?

def faux_actif?
  actif? && date_last_activite <= (Time.now - 6*4.weeks)
end #/ faux_actif?

# ---------------------------------------------------------------------
#
#   PRIVATE METHODS
#
# ---------------------------------------------------------------------

private

  # Retourne la date de dernière activité de l'icarien actif (pour savoir
  # si c'est un vrai actif ou un faux actif)
  def date_last_activite
    @date_last_activite ||= begin
      # Date de dernier document
      begin
        res = db_exec(REQUEST_LAST_ACTIVITY, [id])
        last_document = res.first
        (last_document.nil? ? Time.now : Time.at(last_document[:updated_at].to_i))
      rescue MyDBError => e
        Time.now.to_i
      end
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
      actif:        [],
      faux_actifs:  [],
      candidat:     [],
      inactif:      [],
      recu:         [],
      pause:        [],
      destroyed:    [],
      undefined:    [],
      guest:        []
    }
    all_but_users_out.each do |u|
      state = u.statut
      if u.actif? && not(u.vrai_actif?)
        state = :faux_actifs
      end
      # On place l'icarien dans la liste en fonction de son statut
      @listes[state] << u
    end
  end #/ dispatch_all_users

def vrais_actifs  ; @listes[:actif]       end
def faux_actifs   ; @listes[:faux_actifs] end
def en_pause      ; @listes[:pause]       end
def anciens       ; @listes[:inactif]     end
def candidats     ; @listes[:candidat]    end
def recus         ; @listes[:recu]        end

# OUT   {Array} Tous les icariens sauf les administrateurs, les détruits et
#       John Doe.
def all_but_users_out
  @all_but_users_out ||= find("id > 9 AND SUBSTRING(options,4,1) = 0").values
end #/ all_but_users_out

end #/<< self

# Les templates des différents boutons
BOUTON_FRIGO  = '<span class="tool"><a href="contact/frigo?op=contact&touid=%i" class="btn discret">'+UI_TEXTS[:btn_message_frigo]+'</a></span>'
BOUTON_MAIL   = '<span class="tool"><a href="contact?ui=%i" class="btn discret">'+UI_TEXTS[:btn_lui_ecrire]+'</a></span>'
BOUTON_HISTO  = '<span class="tool"><a href="bureau/historique?uid=%i" class="btn discret">'+UI_TEXTS[:btn_voir_historique]+'</a></span>'
BOUTON_EDIT   = '<span class="tool"><a href="admin/icarien?uid=%i" class="btn discret">'+UI_TEXTS[:btn_edit]+'</a></span>'
BOUTON_VISIT_AS  = '<span class="tool"><a href="bureau/home?op=visitas&touid=%i" class="btn">Visiter comme %s</a></span>'

# La "carte" template d'un icarien actif
CARD_ACTIF = <<-HTML.strip
<div id="icarien-%{id}" class="icarien %{class_statut}">
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

# L'ajout si l'icarien avec un module précédent
SPAN_PRECEDEMMENT = <<-HTML.strip
<span> Précédemment, %{pseudo} a suivi %{modules_suivis}.</span>
HTML

# Le modèle de carte de l'icarien inactif
CARD_INACTIF = <<-HTML.strip
<div id="icarien-%{id}" class="icarien inactif">
  <span class="pseudo big">%{picto} %{pseudo}</span> a travaillé à l’atelier du
  <span class="date-signup">%{date_signup}</span> au <span class="date signout">%{date_signout}</span>
  <span class="duree">(%{duree})</span>.
  <span class="small">%{pseudo} a suivi %{modules_suivis}.</span>
  %{div_tools}
</div>
HTML

# Module de carte pour un candidat
CARD_CANDIDAT = <<-HTML.strip
<div id="icarien-%{id}" class="icarien candidat">
<span class="pseudo big">%{picto} %{pseudo}</span> vient de déposer sa candidature. %{Elle} est en attente de réponse.
</div>
HTML

# Module de carte pour un reçu pas encore en cours de travail
CARD_RECU_INACTIF = <<-HTML.strip
<div id="icarien-%{id}" class="icarien recu">
  <span class="pseudo big">%{picto} %{pseudo}</span> vient d’être reçu%{e} à l’atelier.
  %{modules_suivis}
  %{div_tools}
</div>
HTML

# Le modèle pour l'ajout des modules suivis et terminés
SPAN_MODULES_SUIVIS = <<-HTML.strip
%{pseudo} a suivi le%{s} module%{s} %{modules}
HTML

# Le template du texte à ajouter quand l'icarien est en pause.
SPAN_PAUSE = '<span class="pause"> Actuellement %{pseudo} est en pause.</span>'

REQUEST_LAST_ACTIVITY = "SELECT updated_at FROM icdocuments WHERE user_id = ? ORDER BY updated_at DESC LIMIT 1"

end #/User
