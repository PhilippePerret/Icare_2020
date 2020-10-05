# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{Emoji.get('objets/card').page_title+ISPACE}Candidater"
  end
  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id) == 'signup-form'
      user.check_signup_and_record
    end
  end
  # Fabrication du body
  def build_body
    @body = if user.inscription_ok?
              deserb('signup_ok', self)
            else
              signup_form
            end
  end
end #/HTML
