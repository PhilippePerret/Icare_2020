# encoding: UTF-8
require_module('forms')
class HTML
  def titre
    "📧#{SPACE}Contact".freeze
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
    form = Form.new(id:'contact-form', size:700)
    rows = {
      'Titre' => {name:'envoi_titre', type:'text'},
      'Message' => {name:'envoi_message', type:'textarea'}
    }
    unless user.icarien?
      rows.merge!('Votre mail' => {name:'envoi_mail', type:'text'})
      rows.merge!('Confirmation' => {name:'envoi_mail_confirmation', type:'text'})
    end
    form.rows = rows
    form.submit_button = 'Envoyer'.freeze
    form.out
  end #/ formulaire

  def traite_envoi
    if user.icarien?
      mail = user.data[:mail]
    else
      # Mail fourni en dur
      # TODO
    end

  end #/ traite_envoi
end #/HTML
