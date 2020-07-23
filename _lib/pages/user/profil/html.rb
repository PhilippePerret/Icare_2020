# encoding: UTF-8
class HTML
  def titre
    require './_lib/pages/bureau/xrequired/required'
    "#{RETOUR_BUREAU}#{user.femme? ? EMO_ETUDIANTE : EMO_ETUDIANT}#{ISPACE}Votre profil"
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
