# encoding: UTF-8
require_modules(['form','frigo'])
class HTML
  def titre
    "#{RETOUR_BUREAU}🌡️ Votre porte de frigo".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
    if param(:form_id)
      form = Form.new
      if form.conform?
        case param(:form_id)
        when 'discussion-phil-form'
          start_discussion_with_phil
        when 'discussion-form'
          add_message_to_discussion
        end
      end #/fin de si le formulaire est conforme
    end
  end
  def build_body
    # Construction du body
    vue = if param(:disid) # une discussion choisie
            'discussion'.freeze
          else
            'body'.freeze
          end
    # On construit le body
    @body = deserb("vues/#{vue}", user)
  end

  def start_discussion_with_phil
    tit = safe(param(:frigo_titre).nil_if_empty) || raise(ERRORS[:titre_discussion_required])
    msg = safe(param(:frigo_message).nil_if_empty) || raise(ERRORS[:message_discussion_required])
    FrigoDiscussion.create([phil], tit, msg)
  rescue Exception => e
    erreur e.message
  end #/ start_discussion_with_phil

  # Pour ajouter un message à la discussion courante.
  # - L'ID de la discussion est contenu dans param(:disid)
  # - Le message est contenu dans param(:frigo_message)
  def add_message_to_discussion
    FrigoDiscussion.get(param(:disid))&.add_message({auteur:user, message:param(:frigo_message)})
  end #/ add_message_to_discussion
end #/HTML
