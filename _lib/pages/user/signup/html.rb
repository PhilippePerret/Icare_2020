# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "🚪 Candidater".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id) == 'signup-form'
      user.check_signup
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
