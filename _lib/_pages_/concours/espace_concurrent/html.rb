# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}#{UI_TEXTS[:concours_titre_participant]}"
  end #/titre

  def usefull_links
    ul = []
    ul << Tag.link(route:"#{route}#concours-informations", text: "Informations concours")
    ul << Tag.link(route:"#{route}#concours-preferences", text: "Vos préférences")
    if concurrent.synopsis.fiche_lecture.downloadable?
      ul << Tag.link(route:"#{route}#chargement-fiche-lecture", text: "Fiche lecture")
    end
    if Concours.current.phase1?
      ul << Tag.link(route:"#{route}#concours-fichier-candidature", text: "Envoi fichier")
    end
    ul << Tag.link(route:"#{route}#concours-historique", text: "Historique participations")
    ul << Tag.link(route:"#{route}#concours-destruction", text:"Destruction profil")
    return ul
  end #/ usefull_links

  # Code à exécuter avant la construction de la page
  def exec
    try_reconnect_concurrent(required = true)
    @concours = Concours.new(ANNEE_CONCOURS_COURANTE)
    if param(:form_id)
      return if not Form.new.conform?
      case param(:form_id)
      when 'concours-fichier-form' # Soumission du fichier de candidature
        require_xmodule('consigne_fichier')
        consigne_fichier_candidature
      when 'destroy-form'
        require_xmodule('destroy')
        concurrent.destroy
      end
    elsif param(:op)
      case param(:op)
      when 'logout'
        concurrent.logout
      when 'nonfl'
        concurrent.change_pref_fiche_lecture(false)
        message("D'accord, vous ne recevrez plus la fiche de lecture.")
      when 'ouifl'
        concurrent.change_pref_fiche_lecture(true)
        message("D'accord, vous recevrez la fiche de lecture.")
      when 'nonwarn'
        concurrent.change_pref_warn_information(false)
        message("D'accord, vous ne recevrez plus d'informations sur le concours.")
      when 'ouiwarn'
        concurrent.change_pref_warn_information(true)
        message("D'accord, vous recevrez les informations sur le concours.")
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
