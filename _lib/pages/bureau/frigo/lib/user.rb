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
  discussions.count > 0
end #/ has_discussions?

# Retourne la liste des discussions courantes de l'icarien
def discussions
  @discussions ||= begin
    db_get_all('frigo_discussions', {user_id: id}).collect do |ddis|
      FrigoDiscussion.instantiate(ddis)
    end
  end
end #/ discussions

end #/User
