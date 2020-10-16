# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{UI_TEXTS[:concours_titre_participant]}"
  end #/titre

  def usefull_links
		[
			Tag.link(route:"concours/accueil", text:"Accueil du concours")
		]
	end

  # Code à exécuter avant la construction de la page
  def exec
    @concurrent = Concurrent.new(concurrent_id: session['concours_user_id'], session_id: session.id)
    @concours = Concours.new(ANNEE_CONCOURS_COURANTE)
    if param(:op)
      case param(:op)
      when 'nonfl'
        concurrent.change_pref_fiche_lecture(false)
        message("D'accord, vous ne recevrez plus la fiche de lecture.")
      when 'ouifl'
        concurrent.change_pref_fiche_lecture(true)
        message("D'accord, vous recevrez la fiche de lecture.")
      end
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
