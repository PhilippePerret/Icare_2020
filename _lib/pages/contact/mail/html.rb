# encoding: UTF-8
require_modules(['form','mail'])
MESSAGES.merge!({
  confirme_envoi: 'Votre message a bien été transmis à %s.'
})
class HTML
  def titre
    "#{Emoji.get('objets/lettre-mail').page_title+ISPACE}Contact".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id) == 'contact-form'
      traite_envoi
    end
  end
  def build_body
    # Construction du body
    @body = formulaire
  end

  # Construit et retourne le formulaire
  def formulaire
    form = Form.new(id:'contact-form', size:700, route:route.to_s, libelle_size:100, value_size:600)
    rows = {
      'Titre'   => {name:'envoi_titre', type:'text', value:param(:envoi_titre)},
      'Message' => {name:'envoi_message', type:'textarea', height:260, value:param(:envoi_message)}
    }
    if user.guest?
      rows.merge!('Votre mail' => {name:'envoi_mail', type:'text'})
      rows.merge!('Confirmation' => {name:'envoi_mail_confirmation', type:'text'})
    end
    form.rows = rows
    form.submit_button = 'Envoyer'.freeze
    form.out
  end #/ formulaire

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
    log("Envoi du message avec dmail = #{dmail.inspect}")
    Mail.send(dmail)
    destinataire = 'Phil'
    message(MESSAGES[:confirme_envoi] % destinataire)
    param({envoi_titre:nil, envoi_message:nil, envoi_mail:nil, envoi_mail_confirmation:nil})
  end #/ traite_envoi
end #/HTML
