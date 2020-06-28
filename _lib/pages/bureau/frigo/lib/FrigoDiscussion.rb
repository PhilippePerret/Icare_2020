# encoding: UTF-8
=begin
  Class FrigoDiscussion

=end
class FrigoDiscussion < ContainerClass
  TABLE_USERS = 'frigo_users'.freeze
  TABLE_DISCUSSIONS = 'frigo_discussions'.freeze

  # Requête pour obtenir toutes les discussion de l'user
  # TODO Pour le moment, elles sont classées par ordre de création inverse
  # (les plus récentes en premier), plus tard, on pourra mettre en premier
  # celles qui ont reçu le dernier message.
  REQUEST_DISCUSSIONS_USER = <<-SQL
  SELECT
    dis.id AS discussion_id, u.pseudo AS owner_pseudo
    FROM `frigo_users` AS fu
    INNER JOIN `frigo_discussions` AS dis ON dis.id = fu.discussion_id
    INNER JOIN `users` AS u ON dis.user_id = u.id
    WHERE fu.user_id = %i
    ORDER BY dis.created_at DESC
  SQL
class << self
  def table
    @table ||= TABLE_DISCUSSIONS
  end #/ table
  def table_messages
    @table_messages ||= 'frigo_messages'
  end #/ table_messages
  def table_users
    @table_users ||= TABLE_USERS
  end #/ table_users

  # Retourne la liste (formatée) des discussions de l'icarien (ou moi)
  # d'identifiant +user_id+
  # +user_id+   {Integer|User} Soit l'identifiant de l'utilisateur soit lui-même
  def discussions_of user_id
    user_id = user_id.id if user_id.is_a?(User)
    db_exec(REQUEST_DISCUSSIONS_USER % [user_id]).collect do |ddis|
      Tag.lien(route:"bureau/frigo?disid=#{ddis[:discussion_id]}", text:"Discussion ##{ddis[:discussion_id]} de #{ddis[:owner_pseudo]}", class:'adiscussion')
    end.join
  end #/ discussions_of

  # Initier une nouvelle discussion (par l'user courant), avec +others+, liste
  # des autres icariens et le message +message+
  def create(others, message, options = nil)
    pseudo_others =  others.collect{|u| u.pseudo}
    # On crée la discussion
    discussion_id = db_compose_insert(table, {user_id:user.id})
    # On crée le message
    message_id = db_compose_insert(table_messages, {discussion_id:discussion_id, user_id: user.id, content:message})
    # On indique l'ID du dernier message de la discussion
    db_compose_update(table, discussion_id, {last_message_id: message_id})
    others.each do |other|
      # On crée la rangée dans frigo_users pour faire le lien entre la
      # discussion et l'icarien (ou l'admin). On indiquant que son
      # dernier message est nil.
      other.add_discussion(discussion_id)
    end
    # On ajoute aussi ce message pour celui qui a initié la discussion
    db_compose_insert(table_users, {discussion_id:discussion_id, user_id:user.id, last_checked_at:Time.now.to_i + 10})

    # Message de confirmation
    il_devrait = others.count > 2 ? 'Ils devraient' : 'Il devrait'
    message("La discussion avec #{pseudo_others.join(VG)} est initiée. Il devrait vous répondre très prochainement.")
  end #/ create

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

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
  liste = messages
  liste = liste.reverse if options[:inverse]
  liste.collect { |message| message.out(options) }.join
end #/ out

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
