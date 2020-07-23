# encoding: UTF-8
require_module('form')
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
    unless user.guest?
      mail = user.data[:mail]
    else
      # Mail fourni en dur
      # TODO
    end

  end #/ traite_envoi
end #/HTML
