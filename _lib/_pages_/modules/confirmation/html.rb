# encoding: UTF-8
class HTML
  attr_reader :absmodule
  def titre
    "#{RETOUR_MODULES+Emoji.get('gestes/parle').page_title+ISPACE}Confirmation de commande".freeze
  end
  # Code à exécuter avant la construction de la page
  def exec
    icarien_required
    require_modules(['watchers', 'absmodules'])
    @absmodule = AbsModule.get(param(:mid))
    user.watchers.add(:commande_module, {objet_id: absmodule.id, vu_user:true})
    require_module('mail')
    # Envoi d'un mail à l'administration
    MailSender.send(from:user.mail, file:fullpath('mail_admin.erb'), bind:self)
    # Envoi d'un mail de confirmation à l'icarien
    MailSender.send(to:user.mail, file:fullpath('mail_user.erb'), bind:self)
  end
  # Fabrication du body
  def build_body
    @body = deserb('body', self)
  end
end #/HTML
