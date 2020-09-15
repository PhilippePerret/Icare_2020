# encoding: UTF-8
# frozen_string_literal: true
require_modules(['form','mail'])
MESSAGES.merge!({
  confirme_envoi: 'Votre message a bien été transmis à %s.'
})
class HTML
  def mailing_list?
    !!user.admin?
  end #/ mailing_list?
  def titre
    "#{Emoji.get('objets/lettre-mail').page_title+ISPACE}#{titre_per_user}"
  end
  def titre_per_user
    mailing_list? ? 'Mailing-list' : 'Contact'
  end #/ titre_per_user
  # Code à exécuter avant la construction de la page
  def exec
    if user.admin?
      setup_mailing_list
    end
    if param(:op) == 'traite_mailing_list'
      # On passe ici quand on confirme l'envoi du mail en mailing list
      # Seul un administrateur pourra faire ça
      admin_required
      MailingList.traite
    elsif param(:op) == 'detruire_mailing_list'
      admin_required
      MailingList.destroy_saved_mailing
    elsif param(:form_id) == 'contact-form'
      if mailing_list?
        require_relative 'mailing_list'
        MailingList.apercu
      else
        traite_envoi
      end
    end
  end
  def build_body
    # Construction du body
    @body = deserb('body', self)
  end

  def traite_envoi
    dmail = {
      subject: param(:envoi_titre),
      message: param(:envoi_message),
      to: nil,
      from: (user.guest? ? param(:envoi_mail)  : user.data[:mail])
    }
    # Pour déterminer le destinataire
    if param(:envoi_user_id)
      dmail.merge!(to: User.get(param(:envoi_user_id)).mail)
    else
      dmail.merge!(to: phil.mail)
    end
    # On envoie le message
    Mail.send(dmail)
    destinataire = 'Phil'
    message(MESSAGES[:confirme_envoi] % destinataire)
    param({envoi_titre:nil, envoi_message:nil, envoi_mail:nil, envoi_mail_confirmation:nil})
  end #/ traite_envoi


  # Méthode appelée quand le formulaire de contact est utilisé comme formulaire
  # de mailing-list par un administrateur
  def setup_mailing_list
    require_module 'user/helpers/menus'

  end #/ setup_mailing_list
end #/HTML
