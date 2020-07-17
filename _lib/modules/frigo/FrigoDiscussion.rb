# encoding: UTF-8
=begin
  Class FrigoDiscussion
=end
class FrigoDiscussion < ContainerClass

class << self
  def table
    @table ||= TABLE_DISCUSSIONS
  end #/ table
  def table_messages
    @table_messages ||= TABLE_MESSAGES
  end #/ table_messages
  def table_users
    @table_users ||= TABLE_USERS
  end #/ table_users

  # Retourne le formulaire pour créer une nouvelle discussion
  def create_form(destinataire = nil)
    form = Form.new(id:'frigo-discussion-form', route:route.to_s, class:'nomargin nolibelle')
    rows = {
      'Titre'     => {name:'frigo_titre', type:'text', placeholder:'Titre de la discussion'.freeze},
      'Message'   => {name:'frigo_message', type:'textarea', height:200, placeholder:'Premier message de la discussion'.freeze},
      '<dest/>'   => {name:'touid', type:'hidden', value:destinataire&.id},
      '<op/>'     => {name:'op', type:'hidden', value:'pose'}
    }
    form.rows = rows
    toic = destinataire.nil? ? EMPTY_STRING : " de #{destinataire.pseudo}".freeze
    form.submit_button = "Poser ce message sur le frigo#{toic}"
    return form
  end #/ create_form

  # Initier une nouvelle discussion (par l'user courant), avec +others+, liste
  # des autres icariens et le message +message+
  def create(others, titre, msg, options = nil)
    pseudo_others =  others.collect{|u| u.pseudo}
    # On crée la discussion
    discussion_id = db_compose_insert(table, {user_id:user.id, titre:titre})
    # On crée le message
    message_id = db_compose_insert(table_messages, {discussion_id:discussion_id, user_id: user.id, content:msg})
    # On indique l'ID du dernier message de la discussion
    db_compose_update(table, discussion_id, {last_message_id: message_id})
    others.each do |other|
      # On crée la rangée dans frigo_users pour faire le lien entre la
      # discussion et l'icarien (ou l'admin). On indiquant que son
      # dernier message est nil.
      other.add_discussion(discussion_id)
    end
    # On ajoute aussi ce message pour celui qui a initié la discussion
    # [1] Ne pas mettre un nombre trop grand, sinon ça pose problème pendant
    #     les test : un nouveau message posté dans les x secondes après ne
    #     serait pas considéré comme nouveau.
    db_compose_insert(table_users, {discussion_id:discussion_id, user_id:user.id, last_checked_at:Time.now.to_i + 1}) # [1]

    # Message de confirmation
    unless options && options[:no_message]
      il_devrait = others.count > 2 ? 'Ils devraient' : 'Il devrait'
      message("La discussion avec #{pseudo_others.join(VG)} est initiée. Il devrait vous répondre très prochainement.")
    end
  end #/ create


end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Retourne la liste des participants à cette discussion (Array de User(s))
def participants
  @participants ||= begin
    db_exec("SELECT user_id FROM #{FrigoDiscussion::TABLE_USERS} WHERE discussion_id = #{id}".freeze).collect do |ddis|
      User.get(ddis[:user_id])
    end
  end
end #/ participants

# Retourne la liste de TOUS les participants, même ceux qui ont quitté
# la discussion. On l'appelle la "liste historique des participants"
# Cette liste se récupère par rapport aux messages.
# Mais attention : tous les participants n'ont pas forcément laissé de messages
# donc il faut mixer les deux listes, participants et auteurs_messages
def anciens_participants
  @anciens_participants ||= begin
    (auteurs_messages - participants)
  end
end #/ anciens_participants


def auteurs_messages
  @auteurs_messages ||= begin
    db_exec(REQUEST_AUTEURS_MESSAGES % id).collect { |du| User.get(du[:id]) }
  end
end #/ auteurs_messages

# Destruction complète de la discussion
# -------------------------------------
# Cela consiste à :
#  - détruire l'enregistrement dans frigo_discussions
#  - détruire les participations dans frigo_users
#  - détruire tous les messages dans frigo_messages
#  - avertir tous les participants de la suppression (sauf le propriétaire)
def destroy
  # [1] WARNING Il faut impérativement envoyer les mails avant la destruction
  #     dans les tables, ou alors, il faut récupérer les informations avant et
  #     les mettre de côté (titre, participant, owner, etc.) pour pouvoir les
  #     utiliser dans les mails.
  msg_discuss = MAIL_DESTRUCTION % {pseudo: '%s', owner_pseudo:owner.pseudo, titre:titre}
  participants.each do |participant|
    next if participant.id == owner.id # le propriétaire a son propre message
    participant.send_mail({
      subject: TITRE_MAIL_DESTRUCTION,
      message: msg_discuss % participant.pseudo
    })
  end
  # Mettre ça après l'envoi des mails. Cf. [1] ci-dessus
  [
    "DELETE FROM #{FrigoDiscussion::TABLE_DISCUSSIONS} WHERE id = #{id}".freeze,
    "DELETE FROM #{FrigoDiscussion::TABLE_USERS} WHERE discussion_id = #{id}".freeze,
    "DELETE FROM #{FrigoDiscussion::TABLE_MESSAGES} WHERE discussion_id = #{id}".freeze
  ].each do |request|
    db_exec(request)
  end
end #/ destroy

# Retourne l'instance {User} de l'instigateur de la discussion
def owner
  @owner ||= User.get(user_id)
end #/ owner


end #/FrigoDiscussion
