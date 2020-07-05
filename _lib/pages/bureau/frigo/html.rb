# encoding: UTF-8
require_modules(['form','frigo'])
class HTML
  def titre
    unless param(:disid) || (param(:did) && param(:did)!=EMPTY_STRING)
      "#{RETOUR_BUREAU}🌡️ Votre porte de frigo".freeze
    else
      "#{RETOUR_FRIGO}🌡️ Discussion de frigo".freeze
    end
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
    when 'inviter'
      param(:did) || raise(ERRORS[:discussion_required])
      owner_discussion_required || user.admin? || raise(ERRORS[:inviter_requires_owner])
      return
    when 'destroy'
      param(:did) || raise(ERRORS[:discussion_required]) # passage en force
      owner_discussion_required || user.admin? || raise(ERRORS[:destroy_requires_owner])
      return
    when 'annonce_destruction'
      # Méthode appelée quand le possesseur d'une discussion veut la détruire
      param(:did) || raise(ERRORS[:discussion_required]) # passage en force
      owner_discussion_required || user.admin? || raise(ERRORS[:destroy_requires_owner])
      FrigoDiscussion.get(param(:did)).annonce_destruction
      return
    when 'quitter_discussion'
      # Méthode appelée quand l'user clique sur le bouton pour quitter la
      # discussion sur laquelle il se trouve
      param(:did) || raise(ERRORS[:discussion_required]) # passage en force
      user.quit_discussion(param(:did))
      param(:did, EMPTY_STRING) # Pour le titre
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
        when 'discussion-all-form'
          start_discussion_with_all # je lance une discussion
        when 'discussion-phil-form'
          start_discussion_with_phil # un icarien lance une discuss avec moi
        when 'discussion-form'
          add_message_to_discussion
        end
      end #/fin de si le formulaire est conforme
    end
  rescue Exception => e
    log(e)
    param(:op, '')
    erreur(e.message)
  end #/exec

  # Construction du corps de la page
  def build_body
    # Construction du body
    vue = if param(:op) == STRINGS[:destroy] && !param(:confirmed)
            STRINGS[:destroy]
          elsif param(:op) == STRINGS[:inviter]
            STRINGS[:inviter]
          elsif param(:op) == STRINGS[:download]
            STRINGS[:download]
          elsif param(:disid)  # une discussion choisie
            STRINGS[:discussion]
          else
            STRINGS[:home]
          end
    # On construit le body
    @body = deserb("vues/#{vue}", user)
  end

  # Méthode appelée quand un icarien lance une discussion avec moi
  def start_discussion_with_phil
    tit = safe(param(:frigo_titre).nil_if_empty) || raise(ERRORS[:titre_discussion_required])
    msg = safe(param(:frigo_message).nil_if_empty) || raise(ERRORS[:message_discussion_required])
    FrigoDiscussion.create([phil], tit, msg)
  rescue Exception => e
    erreur e.message
  end #/ start_discussion_with_phil

  def start_discussion_with_all
    tit = safe(param(:frigo_titre).nil_if_empty) || raise(ERRORS[:titre_discussion_required])
    msg = safe(param(:frigo_message).nil_if_empty) || raise(ERRORS[:message_discussion_required])
    # On fait la liste des icariens en fonction des cases à cocher

    target =  case param(:target)
              when NilClass
                return erreur(ERRORS[:invites_required])
              when Array
                param(:target).inject(0){|t, n| t + n.to_i}
              else
                param(:target).to_i
              end

    # On établit la condition
    conditions = ["SUBSTRING(options,4,1) != '1'"] # non détruit
    conditions << "SUBSTRING(options,1,1) = 0" # pas un administrateur
    bit17_in = []
    if target & 1 > 0 # => il faut prendre les actifs
      bit17_in << '3'
      bit17_in << '4'
    end
    if target & 2 > 0 # => il faut prendre les inactifs
      bit17_in << '5'
    end
    if target & 4 > 0 # => il faut prendre les icariens à l'essai
      bit17_in << '2'
    end
    if target & 8 > 0 # => il ne faut pas prendre les trop vieux (> 5 ans)
      conditions << "updated_at > #{Time.now.to_i - 5 * 365.days}"
    end
    unless bit17_in.empty?
      if bit17_in.count == 1
        conditions << "SUBSTRING(options,17,1) = #{bit17_in.first}"
      else
        conditions << "SUBSTRING(options,17,1) IN (#{bit17_in.join(VG)})"
      end
    end

    # On prend les instances icariens qui seront concernées
    conditions = conditions.join(AND)
    request = "SELECT id, pseudo, mail FROM `users` WHERE #{conditions}".freeze
    allusers = db_exec(request).collect{|duser|User.instantiate(duser)}

    if allusers.empty?
      erreur ERRORS[:no_participants_found]
    else
      # On crée la discussion
      FrigoDiscussion.create(allusers, tit, msg)
    end

  end #/ start_discussion_with_all

  # Pour ajouter un message à la discussion courante.
  # - L'ID de la discussion est contenu dans param(:disid)
  # - Le message est contenu dans param(:frigo_message)
  def add_message_to_discussion
    FrigoDiscussion.get(param(:disid))&.add_message({auteur:user, message:param(:frigo_message)})
  end #/ add_message_to_discussion

  private

    # Retourne FALSE si l'user courant n'est pas le propriétaire de la
    # discussion (et qu'il n'est pas un administrateur)
    def owner_discussion_required
      discussion = FrigoDiscussion.get(param(:disid)||param(:did))
      return discussion.owner.id == user.id
    end #/ owner_discussion_required

end #/HTML
