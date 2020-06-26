# encoding: UTF-8
=begin
  Class FrigoDiscussion

=end
class FrigoDiscussion < ContainerClass
class << self
  def table
    @table ||= 'frigo_discussions'
  end #/ table
  def table_messages
    @table_messages ||= 'frigo_messages'
  end #/ table_messages
  def table_users
    @table_users ||= 'frigo_users'
  end #/ table_users

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
      db_compose_insert(table_users, {discussion_id: discussion_id, user_id: other.id, last_message_id: nil})
    end
    il_devrait = others.count > 2 ? 'Ils devraient' : 'Il devrait'
    message("La discussion avec #{pseudo_others.join(VG)} est initiée. Il devrait vous répondre très prochainement.")
  end #/ create

end # /<< self
end #/FrigoDiscussion < ContainerClass
