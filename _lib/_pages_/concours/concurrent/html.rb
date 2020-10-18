# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}#{UI_TEXTS[:concours_titre_participant]}"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    session['concours_user_id'] || begin
      erreur(ERRORS[:concours_login_required])
      return redirect_to("concours/identification")
    end
    @concurrent = Concurrent.new(concurrent_id: session['concours_user_id'], session_id: session.id)
    @concours   = Concours.new(ANNEE_CONCOURS_COURANTE)
    if param(:op)
      case param(:op)
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
