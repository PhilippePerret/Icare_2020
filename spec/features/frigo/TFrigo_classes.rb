# encoding: UTF-8
=begin
  Classes pour les tests
=end

class TFrigo
class << self
  include Capybara::DSL
  def user_rejoint_son_frigo(udes)
    send("login_#{udes}".to_sym) # par exemple login_benoit
    click_on 'Bureau'
    click_on 'Porte de frigo'
  end #/ user_rejoint_son_frigo

  # === EXPECTATIONS ===


  # === PROPRIÉTÉS ===
  def count_messages
    db_count('frigo_messages')
  end #/ count_messages
end # /<< self

end #/TFrigo

class TDiscussion
class << self

  def get disid
    @items ||= {}
    @items[disid.to_i] ||= TDiscussion.instantiate(db_get('frigo_discussions',{id:disid.to_i}))
  end #/ get

  def get_by_titre(titre)
    @items_by_titre ||= {}
    @items_by_titre[titre] ||= begin
      @req_by_titre ||= "SELECT id FROM `frigo_discussions` WHERE titre = ?".freeze
      get(db_exec(@req_by_titre, [titre]).first[:id])
    end
  end #/ get_by_titre

  # Retourne l'instance {TFrigoDiscussion} de la discussion entre
  # les users +users+ {Array de User} d'index +index+ (entendu qu'il peut
  # y avoir plusieurs discussions)
  def between(users, index = 0)
    users_ids = users.collect{|u|u.id}.join(', ')
    request = <<-SQL.freeze
    SELECT fd.id, fd.titre, fd.last_message_id, fd.created_at, fd.updated_at
      FROM `frigo_discussions` AS fd
      INNER JOIN `frigo_users` AS fu ON fu.discussion_id = fd.id
      WHERE
        fd.user_id IN (#{users_ids})
        AND fu.user_id IN (#{users_ids})
    SQL
    return instantiate(db_exec(request)[index])
  end #/ between

  def instantiate(donnees)
    d = new(donnees[:id])
    d.data = donnees
    return d
  end #/ instantiate

end # /<< self
# ---------------------------------------------------------------------
#
#   INSTANCE
#
# ---------------------------------------------------------------------
attr_reader :data, :id
def initialize(id)
  @id = id
end #/ initialize
def data= values
  @data = values
end #/ data= values
def data
  @data ||= db_get('frigo_discussions', id)
end #/ data

def la_chose
  @la_chose ||= "la discussion “#{titre}”"
end #/ la_chose

def titre       ; @titre      ||= data[:titre]      end
def user_id     ; @user_id    ||= data[:user_id]    end
def created_at  ; @created_at ||= data[:created_at] end
def updated_at  ; @updated_at ||= data[:updated_at] end
def last_message_id ; @last_message_id ||= data[:last_message_id] end #/ titre

def owner
  @owner ||= TUser.get(user_id)
end #/ owner

def messages
  @messages ||= begin
    request = <<-SQL
    SELECT id, discussion_id, content, user_id, created_at, updated_at
      FROM `frigo_messages`
      WHERE discussion_id = #{id}
    SQL
    db_exec(request).collect { |dmessage| TFMessage.new(*dmessage.values) }
  end
end #/ messages
end #/TFrigoDiscussion


class TUser

  def la_chose
    @la_chose ||= "l'user #{pseudo}"
  end #/ la_chose
  # Retourne le nombre de message de l'icarien (c'est-à-dire le nombre de
  # messages qu'il a écrits)
  def nombre_messages
    db_count('frigo_messages', {user_id: self.id})
  end #/ nombre_messages

  # Retourne les instances {TFMessage} des messages de l'icarien
  def messages
    request = "SELECT id, discussion_id, content, user_id, created_at, updated_at FROM `frigo_messages` WHERE user_id = #{id}".freeze
    db_exec(request).collect { |dm| TFMessage.new(*dm.values) }
  end #/ messages
end #/TUser

TFMessage = Struct.new(:id, :discussion_id, :content, :user_id, :created_at, :updated_at)
