# encoding: UTF-8
=begin
  Class FrigoDiscussion

=end
class FrigoDiscussion < ContainerClass

  # Requête pour obtenir toutes les discussion de l'user
  # TODO Pour le moment, elles sont classées par ordre de création inverse
  # (les plus récentes en premier), plus tard, on pourra mettre en premier
  # celles qui ont reçu le dernier message.
  REQUEST_DISCUSSIONS_USER = <<-SQL
  SELECT
    dis.titre AS titre, dis.id AS discussion_id, u.pseudo AS owner_pseudo
    FROM `frigo_users` AS fu
    INNER JOIN `frigo_discussions` AS dis ON dis.id = fu.discussion_id
    INNER JOIN `users` AS u ON dis.user_id = u.id
    WHERE fu.user_id = %i
    ORDER BY dis.created_at DESC
  SQL
class << self

  # Retourne la liste (formatée) des discussions de l'icarien (ou moi)
  # d'identifiant +user_id+
  # +user_id+   {Integer|User} Soit l'identifiant de l'utilisateur soit lui-même
  def discussions_of user_id
    user_id = user_id.id if user_id.is_a?(User)
    db_exec(REQUEST_DISCUSSIONS_USER % [user_id]).collect do |ddis|
      Tag.lien(route:"bureau/frigo?disid=#{ddis[:discussion_id]}", text:"#{ddis[:titre]} <span class='small'>##{ddis[:discussion_id]}</span>", class:'block')
    end.join
  end #/ discussions_of

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Pour ajouter un message
# +params+
#   :auteur   {User} Instance de l'user qui envoie le message
#   :message  {String} Le message proprement dit (non vérifié)
def add_message(params)
  msg = params[:message].nil_if_empty
  msg || raise(ERRORS[:message_discussion_required])
  msg.length < 12000 || raise(ERRORS[:message_frigo_too_long])
  msg.length > 2 || raise(ERRORS[:message_frigo_too_short])
  # On crée le message
  msg_id = db_compose_insert(FrigoDiscussion.table_messages, {discussion_id:id, user_id: params[:auteur].id, content:msg})
  # On indique l'ID du dernier message de la discussion
  db_compose_update(FrigoDiscussion.table, id, {last_message_id: msg_id})
  # On doit avertir les suiveurs de la discussion
  notify_followers(but: params[:auteur])
  # Si c'est OK, on vide le champ pour ne pas répéter le message
  param(:frigo_message, '')
rescue Exception => e
  erreur(e.message)
end #/ add_message

SUBJECT_NEW_MESSAGE = 'Nouveau message de %s sur votre frigo'.freeze
MESSAGE_NEW_MESSAGE = "
<p>Bonjour %{pseudo},</p>
<p>Je vous informe que %{from} vient de laisser un message sur votre frigo concernant la discussion “%{titre}”.</p>
<p>Vous pouvez #{Tag.lien(route:'bureau/frigo?disid=%{disid}', full:true, text:'rejoindre cette discussion')}  sur votre frigo.</p>
<p>Bien à vous,</p>
<p>Le Bot de l'Atelier Icare</p>
".freeze
# Pour notifier les participants à cette discussion qu'un nouveau message
# a été envoyé
# +params+
#   :but    {User}  Les prévenir tous sauf celui-ci, qui est l'auteur du message
#
def notify_followers(params)
  participants.each do |part|
    next if params[:but].id == part.id
    # - Il ne faut pas l'avertir s'il ne l'a pas demandé
    next if part.option(22) != 1 # pas de notification
    # - Il ne faut pas l'avertir s'il a déjà un message précédent pour ce fil
    next if part.has_message_non_lu_before_last?(self)
    part.send_mail({
      subject:(SUBJECT_NEW_MESSAGE % user.pseudo),
      message:(MESSAGE_NEW_MESSAGE % {pseudo:part.pseudo, from:user.pseudo, titre:titre, disid:self.id})
    })
    message(MESSAGES[:follower_warned_for_new_message] % part.pseudo)
  end
end #/ notify_followers

# Retourne la liste des participants à cette discussion (Array de User(s))
def participants
  @participants ||= begin
    db_exec("SELECT user_id FROM #{FrigoDiscussion.table_users} WHERE discussion_id = #{id}".freeze).collect do |ddis|
      User.get(ddis[:user_id])
    end
  end
end #/ participants
# = main =
#
# Affichage de la discussion
#
# +options+
#   :ordre      :inverse/:chrono    Affichage inverse (dernier message au-dessus) ou chronologique
#   :from       Time. Seulement depuis ce temps
#   :new_from   {Time} Les nouveaux seront signalés à partir de cette date
#               Note : c'est le `last_checked_at` de l'user sur la discussion.
def out(options = nil)
  options ||= {}
  content = Tag.div(text:titre, class:'titre-discussion') + liste_messages_formated(options)
  Tag.div(text: content, class:'discussion')
end #/ out

def liste_messages_formated(options)
  liste = messages
  liste = liste.reverse if options[:inverse]
  liste = liste.collect { |message| message.out(options) }.join
  Tag.div(text: liste, class:'messages-discussion')
end #/ liste_messages_formated

# Retourne les messages de la discussion, par order
REQUEST_GET_MESSAGES = 'SELECT * FROM `frigo_messages` WHERE discussion_id = %i ORDER BY `created_at`'.freeze
def messages
  @messages ||= begin
    db_exec(REQUEST_GET_MESSAGES % [id]).collect do |dmes|
      FrigoMessage.instantiate(dmes)
    end
  end
end #/ messages
end #/FrigoDiscussion < ContainerClass
