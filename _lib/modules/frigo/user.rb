# encoding: UTF-8
=begin
  Extension de la class User pour les discussions de frigo
=end
class User
# ---------------------------------------------------------------------
#
#   CLASSE
#
# ---------------------------------------------------------------------
class << self

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------

# Retourne true si l'icarien a des discussions en cours
def has_discussions?
  db_count(FrigoDiscussion::TABLE_USERS, {user_id:id}) > 0
end #/ has_discussions?

# Pour ajouter l'user à la discussion +discussion_id+
def add_discussion(discussion_id)
  db_compose_insert(FrigoDiscussion::TABLE_USERS, {discussion_id: discussion_id, user_id: id, last_checked_at: Time.now.to_i - 100})
end #/ add_discussion

# Retourne la liste des discussions courantes de l'icarien
# NOTE : Celles qu'il a initiées seulement
def discussions
  @discussions ||= begin
    db_get_all(FrigoDiscussion::TABLE_DISCUSSIONS, {user_id: id}).collect do |ddis|
      FrigoDiscussion.instantiate(ddis)
    end
  end
end #/ discussions


=begin
  Méthode permettant de savoir si l'user a déjà été prévenu pour un nouveau
  message dans la discussion +discussion+.
  Il a déjà été prévenu si :
    - il y a un message avant le dernier message qui est plus vieux que la
      date de dernier check de user.
  Donc, il faut que le message réponde à ces critères :
    - created_at > last_check_at de l'user
    - id != last_message_id de la conversation
  Si on en trouve au moins un, on revoie true, sinon on renvoie false
=end
def has_message_non_lu_before_last?(discussion)
  request = <<-SQL.freeze
SELECT COUNT(fm.id)
  FROM `frigo_messages` AS fm
  INNER JOIN `frigo_users` AS fu  ON fu.user_id = fm.user_id
  INNER JOIN `frigo_users` AS fdu ON fdu.discussion_id = fm.discussion_id
  INNER JOIN `frigo_discussions` AS fd ON fm.discussion_id = fd.id
  WHERE fm.discussion_id = #{discussion.id}
    -- Le message doit être plus vieux que le dernier check de l'user
    AND fm.created_at > fu.last_checked_at
    -- Le message ne doit pas être le dernier message de la discussion
    AND fm.id != fd.last_message_id
  SQL
  db_exec(request).first.values.first > 0
end #/ has_message_non_lu_before_last?
end #/User
