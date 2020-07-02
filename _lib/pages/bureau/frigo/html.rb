# encoding: UTF-8
require_modules(['form','frigo'])
class HTML
  def titre
    "#{RETOUR_BUREAU}🌡️ Votre porte de frigo".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
    case param(:op)
    when 'download'
      # Opération appelée quand on veut télécharger la discussion param(:disid)
      # Le paramètre :follow peut définir la suite, quand par exemple il faut
      # détruire la discussion après l'opération.
      param(:disid) || raise(ERRORS[:discussion_required])
      FrigoDiscussion.download_discussion(param(:disid))
      return
    when 'decliner_invitation'
      # Méthode appelée depuis un mail pour décliner une invitation à
      # participer à une discussion
      param(:did) || raise(ERRORS[:discussion_required]) # passage en force
      user.quit_discussion(param(:did))
      return
    when 'destroy'
      # Méthode appelée quand le possesseur d'une discussion veut la détruire
      param(:did) || raise(ERRORS[:discussion_required]) # passage en force
      FrigoDiscussion.destroy(param(:did))
      return
    when 'quitter_discussion'
      # Méthode appelée quand l'user clique sur le bouton pour quitter la
      # discussion sur laquelle il se trouve
      param(:did) || raise(ERRORS[:discussion_required]) # passage en force
      user.quit_discussion(param(:did))
      return
    when 'marquer_lus'
      # On passe par ici quand l'user clique sur le bouton pour marquer une
      # discussion "à jour" c'est-à-dire qu'il a lu tous les nouveaux messages
      # cela change la date de son last_checked_at dans frigo_users
      param(:disid) || raise(ERRORS[:discussion_required]) # passage en force
      user.marquer_discussion_lue(param(:disid))
      return
    when 'send_invitations'
      # On passe par ici quand l'user a demandé à afficher la liste des
      # icarien (et administrateurs) pour les inviter à rejoindre une conversa
      # tion. L'icarien a choisi les icariens et on va leur envoyer une
      # invitation
      param(:disid) || raise(ERRORS[:discussion_required]) # passage en force
      FrigoDiscussion.get(param(:disid)).send_invitations_to(param(:icariens))
      return
    end
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

  # Construction du corps de la page
  def build_body
    # Construction du body
    vue = if param(:op) == 'destroy'.freeze && !param(:confirmed)
            'destroy'.freeze
          elsif param(:op) == 'download'.freeze
            'download'.freeze
          elsif param(:disid)  # une discussion choisie
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
