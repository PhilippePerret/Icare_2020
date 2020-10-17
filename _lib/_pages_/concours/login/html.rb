# encoding: UTF-8
# frozen_string_literal: true
require_module('form')
class HTML
  def titre
    "#{bouton_retour}#{EMO_TITRE}Identification au concours"
  end #/titre

  # Code à exécuter avant la construction de la page
  def exec
    if param(:form_id)
      form = Form.new
      check_concurrent if form.conform?
    end
  end # /exec

  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end # /build_body

  def check_concurrent
    dc = db_exec(REQUEST_CHECK_CONCURRENT, [param(:p_concurrent_id), param(:p_mail)]).first
    if not dc.nil?
      session['concours_user_id'] = param(:p_concurrent_id)
      db_compose_update(DBTABLE_CONCURRENTS, dc[:id], {session_id: session.id})
      redirect_to("concours/concurrent")
    else
      erreur("Désolé, je ne vous remets pas… Merci de vérifier votre adresse mail et le numéro de concurrent qui vous a été remis dans le message de confirmation lors de votre inscription.")
    end
  end #/ check_concurrent

end #/HTML
