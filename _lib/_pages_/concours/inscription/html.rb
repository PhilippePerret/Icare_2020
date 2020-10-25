# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
if user.guest?
  require_js_module(['jquery','flash'])
end
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}#{UI_TEXTS[:titre_page_inscription]}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    try_reconnect_concurrent(required = true)
    require_relative '../xmodules/inscription'
    if param(:form_id)
      if Form.new.conform?
        case param(:form_id)
        when 'concours-signup-form'
          if traite_inscription
            redirect_to("concours/espace_concurrent")
          end
        when 'signup-concours-ancien'
          if traite_inscription_ancien
            redirect_to("concours/espace_concurrent")
          end
        end
      end
    elsif param(:op) == 'signupconcours'
      # Quand un icarien inscrit clique sur le bouton "S'inscrire au concours"
      traite_inscription_icarien
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb("form", self)
  end # /build_body


  def panneau_icarien_concurrent
    deserb("./partials/panneau_icarien_concurrent", self)
  end
  def panneau_signup_pour_icarien
    deserb("./partials/panneau_signup_pour_icarien", self)
  end
  def panneau_visiteur_quelconque
    deserb("./partials/panneau_visiteur_quelconque", self)
  end
  def panneau_ancien_concurrent
    deserb("./partials/panneau_ancien_concurrent", self)
  end

end #/HTML
