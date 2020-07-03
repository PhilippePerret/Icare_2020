# encoding: UTF-8
=begin
  Matchers pour le frigo
=end
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
    expect(page).to have_selector('h2', text: 'porte de frigo'),
      "On doit se trouver sur la porte de frigo de #{icarien.pseudo}, pour lancer ce test."
    discussion = TDiscussion.get_by_titre(titre_discussion)
    lien = 'a[href="bureau/frigo?disid=%i"]' % discussion.id
    lien += '.mark-new' if options[:with_new_messages]
    expect(page).to have_selector(lien, text:'%s#%i (initiée par %s)'.freeze % [titre_discussion, discussion.id, discussion.owner.pseudo])
    expect(db_count('frigo_users', {user_id: icarien.id, discussion_id:discussion.id})).to eq(1)
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
  match do |frigo|
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
    return nombre == users.count
  end
  failure_message do |frigo|
    "Aucune discussion n'existe entre #{users.collect{|u|u.pseudo}.join(', ')}…"
  end
  description do
    "Une discussion existe bien entre #{users.collect{|u|u.pseudo}.join(', ')}"
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
