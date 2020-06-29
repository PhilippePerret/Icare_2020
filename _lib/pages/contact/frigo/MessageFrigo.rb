# encoding: UTF-8
=begin
  Class MessageFrigo
=end
class MessageFrigo

  def frigo_message
    @frigo_message ||= safe(param(:frigo_message).nil_if_empty)
  end #/ message
  def titre_discussion
    @titre_discussion ||= safe(param(:frigo_titre).nil_if_empty)
  end #/ titre_discussion

  def formated_message
    @formated_message ||= frigo_message.gsub(/\n/,'<br>')
  end #/ formated_message

  def destinataire
    @destinataire ||= html.destinataire
  end #/ destinataire

  # Pour poser le message sur le frigo (c'est donc ici qu'on le créé)
  # Note : en fait, pour un non icarien, on envoie un mail
  def pose
    if user.icarien?
      # <= C'est un icarien qui contacte
      # => On crée vraiment un message sur le frigo
      FrigoDiscussion.create([destinataire], titre_discussion, frigo_message, {no_message:true})
    else
      # <= C'est un invité qui contacte
      # => On envoie un mail
      destinataire.send_mail({
        subject:MESSAGES[:mail_guest_subject],
        message: MESSAGES[:guest_message] % {
          pseudo:destinataire.pseudo,
          message: formated_message,
          mail: guest_mail
        }
      })
    end
    param(:op, 'confirm'.freeze)
  end #/ pose

  # Retourne TRUE si le message est valide
  def ok?
    html.destinataire_contactable? || raise(ERRORS[:icarien_not_contactable])
    frigo_message || raise(ERRORS[:frigo_message_required])
    titre_discussion || raise(ERRORS[:frigo_titre_discussion_required])
    if user.guest?
      guest_mail || raise(ERRORS[:mail_required_for_guest])
      conf_mail = param(:guest_mail_conf).nil_if_empty
      conf_mail == guest_mail || raise(ERRORS[:guest_mail_conf_not_match])
    end
    return true
  rescue Exception => e
    erreur(e.message)
    param(:op, 'contact'.freeze) # Revenir au formulaire
    return false
  end #/ ok?

  def guest_mail
    @guest_mail ||= param(:guest_mail).nil_if_empty
  end #/ guest_mail
end #/MessageFrigo
