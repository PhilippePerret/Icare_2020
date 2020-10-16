# encoding: UTF-8
# frozen_string_literal: true
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

# Pour quitter la discussion d'ID discussion_id
def quit_discussion(discussion_id)
  discussion = FrigoDiscussion.get(discussion_id)
  req = <<-SQL
DELETE FROM `#{FrigoDiscussion::TABLE_USERS}`
  WHERE user_id = ? AND discussion_id = ?
  SQL
  db_exec(req, [self.id, discussion_id.to_i])
  message(MESSAGES[:confirmation_quit_discussion] % discussion.titre)
  # On avertit le propriétaire de la discussion
  if discussion.owner.id != self.id
    # <= L'auteur courant n'est pas le créateur de la discussion
    # => On peut envoyer un mail d'information
    discussion.owner.send_mail(subject:MESSAGES[:subject_depart_discussion], message:(MESSAGES[:message_depart_discussion] % {owner:discussion.owner.pseudo, pseudo: self.pseudo, titre:discussion.titre}))
  end
end #/ quit_discussion

# Retourne la liste des discussions courantes de l'icarien
# NOTE : Celles qu'il a initiées seulement
def discussions
  @discussions ||= begin
    db_get_all(FrigoDiscussion::TABLE_DISCUSSIONS, {user_id: id}).collect do |ddis|
      FrigoDiscussion.instantiate(ddis)
    end
  end
end #/ discussions

# Retourne la date de dernier check de l'icarien pour la discussion d'ID
# discussion_id
def last_check_discussion(discussion_id)
  db_get(FrigoDiscussion::TABLE_USERS, {discussion_id:discussion_id.to_i, user_id:self.id}, ['last_checked_at'])[:last_checked_at]
end #/ last_check_discussion

# Marquer une discussion entièrement lue
def marquer_discussion_lue(discussion_id)
  req = <<-SQL
  UPDATE `#{FrigoDiscussion::TABLE_USERS}`
    SET last_checked_at = ?
    WHERE discussion_id = ? AND user_id = ?
  SQL
  db_exec(req, [Time.now.to_i, discussion_id.to_i, self.id])
  message(MESSAGES[:discussion_marquee_lue])
end #/ marquer_discussion_lue

=begin
Méthode qui renvoie TRUE si l'icarien participant à la discussion doit
être averti d'un nouveau message. La difficulté tient au fait que s'il a
déjà été averti, il ne faut pas l'avertir à nouveau.
Pour ça, on tient à jour deux propriétés :
  last_warned_at    Date de dernier mail envoyé, annonçant un nouveau message
  last_checked_at   Date de dernière vérification de la discussion.
Si un nouveau message est envoyé (cette méthode est appelée dans ce cas-là),
et que last_warned_at est supérieur à last_checked_at (i.e. un message d'alerte
a été envoyé au participant depuis son dernier check, pour cette discussion),
il n'y a rien à faire, le participant a déjà été informé.
Sinon, il faut lui envoyer un mail. Donc la méthode retourne TRUE
=end
REQUEST_WARN_REQUIRED = "SELECT (last_warned_at IS NULL OR last_checked_at > last_warned_at) AS warn_required FROM frigo_users WHERE user_id = ? AND discussion_id = ?"
def warn_required_for?(discussion)
  db_exec(REQUEST_WARN_REQUIRED,[self.id, discussion.id]).first[:warn_required] == 1
end #/ get_last_warned_and_checked_on_discussion

def set_last_warn_discussion(discussion, time = nil)
  time ||= Time.now.to_i
  request = <<-SQL
UPDATE `frigo_users`
  SET last_warned_at = ?
  WHERE user_id = ? AND discussion_id = ?
  SQL
  db_exec(request, [time.to_s, self.id, discussion.id])
end #/ set_last_warn_discussion
end #/User
