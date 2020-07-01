# encoding: UTF-8
require_modules(['form','frigo'])
class HTML
  def titre
    "Porte de frigo".freeze
  end

  # Code à exécuter avant la construction de la page
  # Rappel : ce
  def exec
    if param(:form_id)
      form = Form.new
      exec_operation if form.conform?
    end
  end

  # Exécution de l'opération voulue (normalement, ici, il n'y a que le dépôt
  # du message sur le frigo, s'il est valide)
  def exec_operation
    case param(:op)
    when 'pose'
      msg = MessageFrigo.new
      msg.ok? || return
      msg.pose
    else
      raise("Opération #{param(:op)} inconnue…".freeze)
    end
  end #/ exec_operation

  # Fabrication du body
  def build_body
    vue = if param(:touid).nil?
            'body'
          elsif destinataire_contactable?
            case param(:op)
            when 'contact'  then 'form'
            when 'confirm'  then 'confirmation'
            else 'body'
            end
          else
            'interdit'
          end
    # On construit la vue
    @body = deserb("vues/#{vue}", self)
  end

  def destinataire_contactable?
    return true if user.admin?
    return true if user.icarien? && (destinataire.type_contact_icariens & 2 > 0)
    return true if user.guest? && (destinataire.type_contact_world & 2 > 0)
    return false
  end #/ destinataire_contactable?

  def discussion_creation_form
    log("-> HTML#discussion_creation_form")
    FrigoDiscussion.create_form(destinataire)
  end #/ discussion_creation_form

  def destinataire
    @destinataire ||= User.get(param(:touid))
  end #/ destinataire

  # Un lien pour revenir à son frigo si le visiteur est un icarien
  def retour_frigo_if_icarien
    return '' unless user.icarien?
    Tag.div(text:Tag.lien(route:'bureau/frigo', text:'Votre frigo', class:'btn'), class:'right discret mb1')
  end #/ retour_frigo_if_icarien
end #/HTML
