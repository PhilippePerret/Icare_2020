# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML

  attr_reader :concurrent

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
    @concurrent = Concurrent.new(user_id: session['concours_user_id'], session_id: session.id)
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

end #/HTML
