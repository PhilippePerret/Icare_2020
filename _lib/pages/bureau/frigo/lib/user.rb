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

end #/User
