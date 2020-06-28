# encoding: UTF-8
require_modules(['user/modules'])
class User

  SPAN_PSEUDO   = '<span class="pseudo">%s %s</span>'.freeze
  SPAN_CURRENT_MODULE = '<span class="module">Module “%s”</span>'.freeze
  SPAN_SINCE    = '<span class="since-date">à l’atelier depuis le %s</span>'.freeze
  BOUTON_FRIGO  = '<span class="tool"><a href="bureau/frigo?op=send&toid=%i">message sur son frigo</a></span>'.freeze
  BOUTON_MAIL   = '<span class="tool"><a href="contact?ui=%i">lui écrire</a></span>'.freeze

  # = main =
  #
  # Méthode d'affichage principal de l'icarien dans la salle des icariens
  def out
    div = []
    div << SPAN_PSEUDO % [visage, pseudo]
    if actif?
      div << SPAN_CURRENT_MODULE % absmodule.name
    end
    div << SPAN_SINCE % formate_date(created_at, {duree: true})
    divcontact = []
    if frigo_enabled
      divcontact << BOUTON_FRIGO % id
    end
    if mail_enabled
      divcontact << BOUTON_MAIL % id
    end
    div << Tag.div(text:divcontact.join, class:'contact')
    Tag.div(text: div.join, class:'icarien', id:"icarien-#{id}")
  end #/ out

  # Retourne TRUE si le contact est possible avec l'icarien
  def frigo_enabled
    return true if user.admin? && (type_contact_admin & 2 > 0)
    return true if user.icarien? && (type_contact_icarien & 2 > 0)
    return (type_contact_world & 2) > 0
  end #/ frigo_enabled

  def mail_enabled
    return true if user.admin? && (type_contact_admin & 1 > 0)
    return true if user.icarien? && (type_contact_icarien & 1 > 0)
    return (type_contact_world & 1) > 0
  end #/ mail_enabled

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
