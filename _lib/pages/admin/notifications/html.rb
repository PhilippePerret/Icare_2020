# encoding: UTF-8
require_module('form')
class HTML
  def titre
    "#{RETOUR_ADMIN}🎮 Notifications".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    admin_required
    if param(:wid)
      watcher = Watcher.get(param(:wid))
      watcher.send(param(:op).to_sym) # :run et :unrun principalement
    end
    # J'essaie d'envoyer un mail
    require_module('mail')
    Mail.send(subject:'Message test c’est l’été ?', from:'phil@atelier-icare.net', to:'phil@atelier-icare.net', message:"Un simple message", force:true)
    message "Si je passe ici, c'est que j'ai envoyé le mail"
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', user)
  end
end #/HTML
