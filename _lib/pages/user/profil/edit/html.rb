# encoding: UTF-8
class HTML
  def titre
    "#{RETOUR_PROFIL}#{user.femme? ? '🧛‍♀️' : '🧛🏻‍♂️'} Édition du profil".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    require_module('forms')
    if param(:form_id) == 'profil-form'
      user.check_and_save_profil
    end

  end
  def build_body
    # Construction du body
    @body = user.formulaire_profil
  end
end #/HTML
