# encoding: UTF-8
# frozen_string_literal: true
=begin
  Module User pour les helpers methods
=end
class User

  # Retourne le pseudo de l'icarien lié à son profil
  def linked
    @linked ||= "<a href=\"user/profil?uid=#{id}\" target=\"_blank\">#{pseudo}</a>"
  end #/ linked

  def ref
    @ref ||= "#{pseudo} <span class='small'>(##{id})</span>"
  end #/ ref

  # Permet d'envoyer un message mail à l'icarien
  # +dmail+
  #   subject: Le sujet
  #   message: Le message au format HTML
  def send_mail(dmail)
    require_module('mail')
    Mail.send(dmail.merge!(to: mail))
  end #/ send_mail

  # Retourne le visage de l'utilisateur, en fonction du fait que c'est
  # un homme ou une femme
  def visage
    @face ||= (femme? ? '👩‍🎓' : '👨‍🎓').freeze
  end #/ face

  # Retourne la pastille contenant les notifications non vues
  # Noter qu'ici la méthode est accessible partout sans charger
  # le module 'watchers'
  def pastille_notifications_non_vues(options = nil)
    return '' if self.guest?
    nombre = unread_notifications_count
    return '' if nombre == 0
    Tag.pastille_nombre(nombre, options)
  end
end #/User
