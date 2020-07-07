# encoding: UTF-8
require_modules(['user/modules'])
require_relative 'constants'

class User

  SPAN_PSEUDO   = '<span class="pseudo big">%s %s</span>'.freeze
  SPAN_CURRENT_MODULE = '<span class="module">“%s”</span>'.freeze
  SPAN_SINCE    = '<span class="since-date">, à l’atelier depuis le %s</span>'.freeze
  BOUTON_FRIGO  = '<span class="tool"><a href="contact/frigo?op=contact&touid=%i" class="small btn discret">'+UI_TEXTS[:btn_message_frigo]+'</a></span>'.freeze
  BOUTON_MAIL   = '<span class="tool"><a href="contact?ui=%i" class="small btn discret">'+UI_TEXTS[:btn_lui_ecrire]+'</a></span>'.freeze
  BOUTON_HISTO  = '<span class="tool"><a href="bureau/historique?uid=%i" class="small btn discret">'+UI_TEXTS[:btn_voir_historique]+'</a></span>'.freeze

  SPAN_A_SUIVI = '<span>a suivi </span>'.freeze
  SPAN_SUIT    = '<span>, suit le module </span>'.freeze
  SPAN_EST_CANDIDAT = '<span>, est candidat%s</span>'.freeze
  SPAN_POINT   = '<span>.</span>'.freeze

  # Requête simple pour obtenir les noms des modules suivis par l'icarien
  REQUEST_MODULES_SUIVIS = <<-SQL
SELECT icm.id, abs.name
FROM icmodules AS icm
INNER JOIN absmodules AS abs ON icm.absmodule_id = abs.id
WHERE icm.user_id = %{id}
  SQL

  # = main =
  #
  # Méthode d'affichage principal de l'icarien dans la salle des icariens
  def out
    div = []
    div << SPAN_PSEUDO % [visage, pseudo]
    div << SPAN_SINCE % formate_date(created_at)
    if actif?
      div << SPAN_SUIT + (SPAN_CURRENT_MODULE % absmodule.name)
    elsif candidat?
      div << SPAN_EST_CANDIDAT % fem(:e)
    end
    div << span_modules_suivis # n'écrit quelque chose que s'il y en a
    div << SPAN_POINT
    divcontact = []
    divcontact << BOUTON_HISTO % id if histo_enabled?
    divcontact << BOUTON_FRIGO % id if frigo_enabled?
    divcontact << BOUTON_MAIL  % id if mail_enabled?

    if user.admin?
      # Si c'est l'administrateur qui visite, on peut ajouter
      # d'autres boutons. Par exemple pour voir le détail du profil
      # de l'icarien.

    end
    div << Tag.div(text:divcontact.join, class:'tools')
    Tag.div(text: div.join, class:'icarien', id:"icarien-#{id}")
  end #/ out

  # Retourne le texte du type "Marion a suivi les modules ...". Ce texte
  # s'applique à un ancien icarien comme à un nouveau.
  def span_modules_suivis
    return '' if modules_suivis.count > 0
    plus = modules_suivis.count > 1
    s = plus ? 's' : ''
    "#{pseudo} #{SPAN_A_SUIVI} le#{s} module#{s} #{modules_suivis.collect{|m|m[:name]}.join(VG)}".freeze
  end #/ span_modules_suivis

  # Retourne la liste des modules suivis
  def modules_suivis
    @modules_suivis ||= db_exec(REQUEST_MODULES_SUIVIS % {id: id})
  end #/ modules_suivis

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
  def actifs
    all_but_admin.select { |u| u.actif? }
  end #/ actifs
  def anciens
    all_but_admin.select { |u| u.real? && !u.actif? }
  end #/ anciens
  def candidats
    all_but_admin.select {|u| !u.actif? && !u.real? }
  end #/ candidats
  def all_but_admin
    @all_but_admin ||= find("SUBSTRING(options,1,1) = 0").values
  end #/ all_but_admin
end #/<< self
end #/User
