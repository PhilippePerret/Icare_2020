# encoding: UTF-8
# frozen_string_literal: true
class HTML
  def titre
    require "#{FOLD_REL_PAGES}/bureau/xrequired/required"
    titstr =
      if not(user.admin?) || param(:uid).nil? || param(:uid) == user.id
        "Votre profil"
      elsif user.admin? && not(param(:uid).nil?)
        "Profil de #{owner.pseudo}"
      else
        "Profil"
      end

    "#{RETOUR_BUREAU}#{Emoji.get("humain/etudiant#{owner.fem(:e)}").page_title}#{ISPACE}#{titstr}"
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
  end
  def build_body
    # Construction du body
    @body = deserb('profil', owner)
  end

  # L'icarien dont il faut afficher le profil. Pour le moment, cette propriété
  # ne peut être invoquée que si c'est un administrateur qui visite le site
  def owner
    @owner ||= begin
      if user.admin? && not(param(:uid).nil?)
        User.get(param(:uid))
      else
        user
      end
    end
  end #/ owner
end #/HTML
