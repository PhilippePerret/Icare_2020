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
    form = Form.new(id:'frigo-discussion-form', route:route.to_s, value_size:600, libelle_size:0, class:'nomargin')
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
    db_compose_insert(table_users, {discussion_id:discussion_id, user_id:user.id, last_checked_at:Time.now.to_i + 10})

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

end #/FrigoDiscussion
