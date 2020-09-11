# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    require "#{FOLD_REL_PAGES}/bureau/xrequired/required"
    "#{RETOUR_BUREAU}#{Emoji.get("humain/etudiant#{user.fem(:e)}".freeze).page_title}#{ISPACE}Votre profil"
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
  end
  def build_body
    # Construction du body
    @body = deserb('profil', user)
  end
end #/HTML
