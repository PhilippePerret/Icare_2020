# encoding: UTF-8
class HTML
  def titre
    "#{RETOUR_PROFIL+Emoji.get("humain/etudiant#{user.fem(:e)}".freeze).page_title+ISPACE}Édition du profil".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    require_module('form')
    if param(:form_id) == 'profil-form'
      user.check_and_save_profil
    end

  end
  def build_body
    # Construction du body
    @body = user.formulaire_profil
  end
end #/HTML
