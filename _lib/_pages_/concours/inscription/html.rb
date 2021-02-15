# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
if user.guest?
  require_js_module(['jquery','flash'])
end
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}#{UI_TEXTS[:concours][:titres][:signup_page]}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    try_to_reconnect_visitor(required = false)
    require_xmodule('inscription')
    # Si le visiteur est déjà inscrit ou que le concours est en phase 2 ou
    # supérieur, l'inscription est impossible
    return if inscription_impossible?
    if param(:form_id)
      if Form.new.conform?
        case param(:form_id)
        when 'concours-signup-form'
          traite_inscription
        end
      end
    elsif param(:op) == 'signupcursessancien'
      redirect_to("concours/espace_concurrent") if traite_inscription_ancien
    elsif param(:op) == 'signupconcours'
      # Quand un icarien inscrit clique sur le bouton "S'inscrire au concours"
      icarien_required
      traite_inscription_icarien
    elsif param(:op) == 'sgnupsesscour'
      # Pour un icarien ancien concurrent qui veut participer à la session courante
      icarien_required
      traite_inscription_icarien_session_courante
      redirect_to("concours/espace_concurrent")
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb(panneau_path, self)
  end # /build_body

  def panneau_path
    "./panneau/#{panneau_name}"
  end

  def panneau_name
    case true
    when user.admin?              then 'admin'
    when inscription_impossible?  then 'concours_en_cours'
    when icarien_inscrit?         then 'icarien_deja_inscrit'
    when concurrent_inscrit?      then 'concurrent_deja_inscrit'
    when concours_en_cours?       then 'concours_en_cours'
    when icarien_ancien_inscrit?  then 'icarien_ancien_concurrent'
    when icarien?                 then 'signup_pour_icarien'
    when ancien_concurrent?       then 'ancien_concurrent'
    else 'visiteur_quelconque'
    end
  end #/ panneau_name

  def concours_en_cours?
    Concours.current.phase > 1
  end
  def icarien_inscrit?
    icarien? && user.concurrent_session_courante?
  end
  def icarien_ancien_inscrit?
    icarien? && user.concurrent? && not(user.concurrent_session_courante?)
  end
  def concurrent_inscrit?
    guest? && concurrent && concurrent.current?
  end
  def ancien_concurrent?
    guest? && concurrent && not(concurrent.current?)
  end

  def icarien?
    :TRUE === @is_an_icarien ||= user.guest? ? :FALSE : :TRUE
  end

  def guest?
    :TRUE === @is_a_guest ||= user.guest? ? :TRUE : :FALSE
  end

  def inscription_impossible?
    Concours.current.phase >= 2
  end

end #/HTML
