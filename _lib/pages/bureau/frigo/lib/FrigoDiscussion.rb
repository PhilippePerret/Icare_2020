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
    dis.id AS discussion_id, u.pseudo AS owner_pseudo
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
      Tag.lien(route:"bureau/frigo?disid=#{ddis[:discussion_id]}", text:"Discussion ##{ddis[:discussion_id]} de #{ddis[:owner_pseudo]}", class:'adiscussion')
    end.join
  end #/ discussions_of

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
