# encoding: UTF-8
require_modules(['form'])
class HTML
  def titre
    "#{RETOUR_BUREAU}🌡️ Votre porte de frigo".freeze
  end
  def exec
    # Code à exécuter avant la construction de la page
    icarien_required
    if param(:form_id)
      if param(:form_id) == 'discussion-phil-form'
        form = Form.new
        start_discussion_with_phil if form.conform?
      end
    end
  end
  def build_body
    # Construction du body
    @body = deserb('body', user)
  end


  def start_discussion_with_phil
    mes = safe(param(:discussion_message)) || raise(ERRORS[:message_required])
    FrigoDiscussion.create([phil], mes)
  rescue Exception => e
    erreur e.message
  end #/ start_discussion_with_phil
end #/HTML
