# encoding: UTF-8
=begin
  Matchers pour le frigo
=end
require './_lib/modules/frigo/constants.rb'
require './_lib/pages/bureau/frigo/lib/constants.rb'

RSpec::Matchers.define :have_message do |dmessage|
  match do |sujet|
    dmessage.merge!(user_id: dmessage.delete(:user).id) if dmessage.key?(:user)
    ok = true
    case sujet
    when TDiscussion
    when TUser
    else
      raise "Impossible d'utiliser have_message avec une instance de type #{sujet.class}"
    end
    # puts "dmessage: #{dmessage.inspect}"
    # puts "sujet.messages: #{sujet.messages.inspect}"
    @goods = []
    sujet.messages.each do |message|
      next if dmessage.key?(:after) && message.created_at < dmessage[:after]
      next if dmessage.key?(:before) && message.created_at > dmessage[:before]
      if dmessage.key?(:user_id)
        ok = ok && (message.user_id == dmessage[:user_id])
      end
      if dmessage.key?(:content)
        ok = ok && (message.content.match?(dmessage[:content]))
      end
      @goods << message
    end
    if dmessage.key?(:count)
      # IL doit y avoir un certain nombre de messages
      ok = ok && @goods.count == dmessage[:count]
    end
    return ok
  end

  failure_message do |sujet|
    msg = []
    msg << "#{sujet.la_chose.capitalize} ne contient pas le message."
    if dmessage.key?(:count) && @goods.count != dmessage[:count]
      msg << "Devrait avoir #{dmessage[:count]} message(s), en compte #{@goods.count}…"
    end
    return msg.join(' ')
  end
  description do
    "Le message existe pour #{sujet.la_chose}"
  end
end
RSpec::Matchers.alias_matcher(:have_messages, :have_message)

# Vérifier que +icarien+ ait bien la discussion sur sa porte de frigo et
# dans la base de données.
#
# +options+
#   :with_new_messages    Doit avoir la marque de nouveaux messages
RSpec::Matchers.define :have_discussion do |titre_discussion, options|
  match do |icarien|
    discussion = TDiscussion.get_by_titre(titre_discussion)
    expect(discussion).not_to eq(nil) # existence dans la base de données
    if page.has_css?('h2', text: 'porte de frigo')
      lien = 'a[href="bureau/frigo?disid=%i"]' % discussion.id
      lien += '.mark-new' if options[:with_new_messages]
      expect(page).to have_selector(lien, text:'%s#%i (initiée par %s)'.freeze % [titre_discussion, discussion.id, discussion.owner.pseudo])
    end
    if options[:owner] === true
      expect(discussion.owner.id).to eq(icarien.id),
        "#{icarien.pseudo} devrait être l'instigateur de cette discussion."
    end
    expect(db_count('frigo_users', {user_id: icarien.id, discussion_id:discussion.id})).to eq(1)
    expect(db_count('frigo_messages', {discussion_id: discussion.id})).to be > 0
    true
  end
  description do
    "#{icarien.pseudo} participe à la discussion “#{titre_discussion}”."
  end
  failure_message do |icarien|
    "#{icarien.pseudo} devrait participer à la discussion “#{titre_discussion}”."
  end
end #/:have_discussion

RSpec::Matchers.define :have_discussion_with do |users|
  match do |someone|
    if someone.is_a?(TUser)
      users << someone
    end
    users_ids = users.collect{|u|u.id}.join(', ')
    request = <<-SQL.freeze
    SELECT COUNT(id)
      FROM frigo_discussions AS fd
      INNER JOIN frigo_users AS fu ON fu.discussion_id = fd.id
      WHERE fu.user_id IN (#{users_ids})
        AND fu.discussion_id = fd.id
    SQL
    nombre = db_exec(request)
    if MyDB.error
      erreur(MyDB.error.inspect)
      raise MyDB.error.inspect
    end
    nombre = nombre.first.values.first
    return nombre == users.count # Autant de frigo_users que de participants
  end
  failure_message do |frigo|
    "Aucune discussion n'existe entre #{users.collect{|u|u.pseudo}.join(', ')}…"
  end
  description do
    "Une discussion existe bien entre #{users.collect{|u|u.pseudo}.join(', ')}"
  end
end

# Pour vérifier qu'une discussion n'existe nulle part
RSpec::Matchers.define :have_no_discussion do |dis_id|
  match do |sujet|
    # Normalement, le sujet est TFrigo, mais ça pourrait être
    # un icarien aussi. À voir
    if sujet.respond_to?(:name) && sujet.name == 'TFrigo'
      expect(db_count('frigo_discussions',{id: dis_id})).to eq(0)
      expect(db_count('frigo_users', {discussion_id: dis_id})).to eq(0)
      expect(db_count('frigo_messages', {discussion_id: dis_id})).to eq(0)
    elsif sujet === TUser
      raise "SYSTEM ERROR: Utiliser .not_to have_discussion pour le moment"
    else
      raise "SYSTEM ERROR: la class #{sujet.name} ne peut pas utiliser ce matcher."
    end
    return true
  end #/match

  description do
    "La discussion ##{dis_id} n'existe pas ou plus."
  end
  failure_message do
    "La discussion ##{dis_id} ne devrait plus exister…"
  end
end

RSpec::Matchers.define :have_no_pastille_frigo do
  match do |icarien|
    expect(page).not_to have_selector('div#goto-frigo span.pastille')
  end
  description do
    "La porte de frigo n'a pas ou plus de pastilles indiquant des nouveaux messages"
  end
  failure_message do |icarien|
    "La porte de frigo ne devrait plus avoir de pastille indiquant des nouveaux messages…"
  end
end

RSpec::Matchers.define :have_pastille_frigo do |nombre|

  match do |icarien|
    expect(page).to have_selector('div#goto-frigo > a > span.pastille', text: nombre.to_s)
  end

  failure_message do |icarien|
    "La porte du frigo devrait afficher la pastille avec le nombre #{nombre}.".freeze
  end

  description do
    "La porte du frigo affiche la pastille avec le nombre de messages (#{nombre})".freeze
  end

end

# Pour vérifier qu'un icarien a bien été invité à une discussion
RSpec::Matchers.define :have_been_invited_to_discussion do |titre_discussion, params|
  match do |icarien|
    params ||= {}
    params[:after] ||= Time.now.to_i - 10
    discussion = TDiscussion.get_by_titre(titre_discussion)
    # Marion doit avoir reçu un mail
    TMails.exists?(
      icarien.mail,
      "à rejoindre sa discussion “{titre_discussion}”",
      {
        subject: FrigoDiscussion::SUBJECT_INVITATION,
        after: params[:after]
      }
    )
    # Un enregistrement doit avoir été créé dans frigo_users
    dbdata = {user_id: icarien.id, discussion_id: discussion.id}
    expect(db_count('frigo_users', dbdata)).to eq(1),
      "Il devrait exister un enregistrement avec #{dbdata.inspect} dans la base de données"
    return true
  end
  description do
    "#{icarien.pseudo} a bien été invité à la discussion “#{titre_discussion}”"
  end
  failure_message do |icarien|
    "#{icarien.pseudo} aurait dû être invité à la discussion “#{titre_discussion}”"
  end
end
